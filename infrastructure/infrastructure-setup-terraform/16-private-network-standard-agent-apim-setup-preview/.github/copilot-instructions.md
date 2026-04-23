# Copilot Instructions for Terraform + Azure Foundry (Private Networking)

## Repository intent
This repository provisions a private-first Azure AI Foundry architecture with API Management and Application Gateway using Terraform.

## Core operating rules
- Always run Terraform commands from the code folder.
- Use PowerShell-safe command syntax and avoid shell-specific shortcuts that may break.
- Always run: terraform init (if needed), terraform validate, terraform plan, then terraform apply.
- Prefer saved plans for deterministic deployments.
- Explain expected create/change/destroy counts before apply.

## Safety and blast radius
- Flag any ForceNew or replacement risk before making changes.
- Explicitly call out when a change can recreate networking resources, APIM, or core data services.
- Treat location, SKU, subnet CIDR, and resource naming changes as high risk.
- Never default to enabling public access on private resources; only do it when explicitly requested and clearly mark rollback steps.

## Backend and state
- Prefer remote backend in Azure Storage.
- When backend config changes, use terraform init -reconfigure and handle migration explicitly.
- Do not suggest committing backend.tfvars or any secret-bearing files.

## Azure networking posture
- Keep private endpoints and DNS zone links intact unless explicitly asked to redesign networking.
- For temporary public administration requests, prefer time-bound and scoped access with clear revert instructions.
- APIM Internal mode is not a simple public toggle; treat as architecture-level decision.

## Change style
- Keep edits minimal and targeted.
- Preserve established naming patterns and variable-driven configuration.
- Avoid unrelated refactors.
