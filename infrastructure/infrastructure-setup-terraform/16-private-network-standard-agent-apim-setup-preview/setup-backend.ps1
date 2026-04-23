<#
.SYNOPSIS
    Creates an Azure Storage Account for Terraform remote state and generates a backend config file.

.DESCRIPTION
    This script provisions a dedicated resource group and storage account for storing
    Terraform state remotely in Azure Blob Storage. It uses Azure AD authentication
    (no storage account keys) consistent with the main Terraform configuration.

    After running this script, initialise (or re-initialise) Terraform with:

        cd code
        terraform init -backend-config=../backend.tfvars -migrate-state

    If this is a fresh workspace (no existing local state), omit -migrate-state:

        terraform init -backend-config=../backend.tfvars

.PARAMETER Location
    Azure region for the backend storage account. Defaults to uksouth.

.PARAMETER ResourceGroupName
    Name of the dedicated resource group for the Terraform state. Defaults to rg-tfstate-aifoundry.

.PARAMETER StorageAccountName
    Name of the storage account (globally unique, 3-24 lowercase alphanumeric).
    If not specified, a unique name is generated automatically.

.PARAMETER ContainerName
    Name of the blob container within the storage account. Defaults to tfstate.

.PARAMETER StateKey
    The blob name (key) used for this deployment's state file.
    Defaults to 16-private-network-apim.tfstate.

.EXAMPLE
    .\setup-backend.ps1
    # Creates backend with default settings in uksouth

.EXAMPLE
    .\setup-backend.ps1 -Location eastus -ResourceGroupName rg-my-tfstate
#>
param(
    [string]$Location           = "uksouth",
    [string]$ResourceGroupName  = "rg-tfstate-aifoundry",
    [string]$StorageAccountName = "",
    [string]$ContainerName      = "tfstate",
    [string]$StateKey           = "16-private-network-apim.tfstate"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── 1. Verify Azure CLI is available and logged in ────────────────────────────
Write-Host "`n==> Checking Azure CLI..." -ForegroundColor Cyan
az account show --output none 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Not logged in to Azure CLI. Run 'az login' first."
    exit 1
}

$subscription = az account show --query "{id:id, name:name}" -o json | ConvertFrom-Json
Write-Host "    Subscription : $($subscription.name)" -ForegroundColor Green
Write-Host "    ID           : $($subscription.id)" -ForegroundColor Green

# ── 2. Generate a unique storage account name if not provided ─────────────────
if ([string]::IsNullOrEmpty($StorageAccountName)) {
    # Storage account names: 3-24 chars, lowercase letters and numbers only
    $suffix = -join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
    $StorageAccountName = "tfstate$suffix"
}

Write-Host "`n==> Backend configuration:" -ForegroundColor Cyan
Write-Host "    Resource Group   : $ResourceGroupName"
Write-Host "    Storage Account  : $StorageAccountName"
Write-Host "    Container        : $ContainerName"
Write-Host "    State Key        : $StateKey"
Write-Host "    Location         : $Location"

# ── 3. Create resource group ──────────────────────────────────────────────────
Write-Host "`n==> Creating resource group '$ResourceGroupName'..." -ForegroundColor Cyan
$rgExists = az group exists --name $ResourceGroupName
if ($rgExists -eq "true") {
    Write-Host "    Resource group already exists, skipping." -ForegroundColor Yellow
} else {
    az group create `
        --name $ResourceGroupName `
        --location $Location `
        --output none
    Write-Host "    Created." -ForegroundColor Green
}

# ── 4. Create storage account ─────────────────────────────────────────────────
Write-Host "`n==> Creating storage account '$StorageAccountName'..." -ForegroundColor Cyan
$saExists = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "    Storage account already exists, skipping." -ForegroundColor Yellow
} else {
    az storage account create `
        --name $StorageAccountName `
        --resource-group $ResourceGroupName `
        --location $Location `
        --sku Standard_LRS `
        --kind StorageV2 `
        --access-tier Hot `
        --min-tls-version TLS1_2 `
        --allow-blob-public-access false `
        --https-only true `
        --default-action Allow `
        --output none
    Write-Host "    Created." -ForegroundColor Green
}

# Enable versioning for state file safety
Write-Host "`n==> Enabling blob versioning on storage account..." -ForegroundColor Cyan
az storage account blob-service-properties update `
    --account-name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --enable-versioning true `
    --output none
Write-Host "    Done." -ForegroundColor Green

# ── 5. Create blob container ──────────────────────────────────────────────────
Write-Host "`n==> Creating blob container '$ContainerName'..." -ForegroundColor Cyan
$currentUser = az ad signed-in-user show --query id -o tsv 2>$null
if (![string]::IsNullOrEmpty($currentUser)) {
    # Assign Storage Blob Data Contributor to the current user so we can create the container via Azure AD
    $storageId = az storage account show `
        --name $StorageAccountName `
        --resource-group $ResourceGroupName `
        --query id -o tsv

    Write-Host "    Assigning 'Storage Blob Data Contributor' to current user..." -ForegroundColor Cyan
    az role assignment create `
        --role "Storage Blob Data Contributor" `
        --assignee $currentUser `
        --scope $storageId `
        --output none 2>&1 | Out-Null
    # Role assignment propagation may take a moment
    Write-Host "    Waiting 15s for role assignment to propagate..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
}

$containerExists = az storage container show `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --auth-mode login 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "    Container already exists, skipping." -ForegroundColor Yellow
} else {
    az storage container create `
        --name $ContainerName `
        --account-name $StorageAccountName `
        --auth-mode login `
        --output none
    Write-Host "    Created." -ForegroundColor Green
}

# ── 6. Write backend.tfvars ───────────────────────────────────────────────────
$backendTfvarsPath = Join-Path $PSScriptRoot "backend.tfvars"
$content = @"
# Terraform backend configuration for Azure Storage
# Generated by setup-backend.ps1 on $(Get-Date -Format "yyyy-MM-dd HH:mm")
# DO NOT COMMIT this file - it is listed in .gitignore

resource_group_name  = "$ResourceGroupName"
storage_account_name = "$StorageAccountName"
container_name       = "$ContainerName"
key                  = "$StateKey"
use_azuread_auth     = true
"@
$content | Set-Content -Path $backendTfvarsPath -Encoding utf8
Write-Host "`n==> Written: $backendTfvarsPath" -ForegroundColor Green

# ── 7. Print next steps ───────────────────────────────────────────────────────
Write-Host "`n=========================================================" -ForegroundColor Cyan
Write-Host " NEXT STEPS" -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan
Write-Host "To initialise Terraform with this backend and migrate any" -ForegroundColor White
Write-Host "existing local state to Azure Storage, run:" -ForegroundColor White
Write-Host ""
Write-Host "    cd code" -ForegroundColor Yellow
Write-Host "    terraform init -backend-config=../backend.tfvars -migrate-state" -ForegroundColor Yellow
Write-Host ""
Write-Host "For a fresh workspace with no existing state, omit -migrate-state:" -ForegroundColor White
Write-Host ""
Write-Host "    terraform init -backend-config=../backend.tfvars" -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================================`n" -ForegroundColor Cyan
