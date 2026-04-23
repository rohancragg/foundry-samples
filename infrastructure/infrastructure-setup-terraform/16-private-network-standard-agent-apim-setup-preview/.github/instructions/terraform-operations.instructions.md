---
description: "Operational workflow for Terraform in this repo, including init, backend migration, plan, and apply safety."
applyTo: "code/**/*.tf,code/*.tfvars,setup-backend.ps1"
---

# Terraform Operations Workflow

- Run commands from the code directory by using an explicit chdir flag.
- Avoid issues with powershell argument parsing by using explicit command forms and avoiding Linux-style pipelines or redirects.
- Avoid powershell parsing issues by quoting all terraform command arguments.
- Standard sequence:
  1. terraform init (or init -reconfigure when backend changes)
  2. terraform validate
  3. terraform plan -var-file=example.tfvars -out=tfplan (when deterministic apply is requested)
  4. terraform apply tfplan
- If backend migration is needed, clearly handle prompts and confirm whether to migrate existing state.
- Before apply, summarize plan counts and highlight destructive or replacement actions.
- If apply fails, report the exact failing resource and actionable fix.
- Avoid pipeline commands that alter Terraform argument parsing in PowerShell.
