---
description: "Security and secret-handling rules for Terraform, tfvars, and PowerShell scripts in this repo."
applyTo: "**/*.tf,**/*.tfvars,**/*.ps1"
---

# Security and Secrets

- Never commit secrets, access keys, connection strings, or generated backend config files containing sensitive details.
- Prefer Azure AD authentication over static keys where supported.
- Avoid adding outputs that expose sensitive values.
- If troubleshooting requires viewing sensitive fields, minimize exposure and redact in summaries.
- Keep storage and service public access disabled by default.
- Do not suggest weakening TLS or security defaults for convenience.
