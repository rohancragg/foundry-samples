# Configure the AzApi and AzureRM providers
terraform {
  # Remote state stored in Azure Blob Storage.
  # Initialise with:
  #   terraform init -backend-config=../backend.tfvars [-migrate-state]
  # Run ../setup-backend.ps1 first to create the storage account and generate backend.tfvars.
  backend "azurerm" {}

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.37"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.12"
    }
  }
  required_version = ">= 1.10.0, < 2.0.0"
}
