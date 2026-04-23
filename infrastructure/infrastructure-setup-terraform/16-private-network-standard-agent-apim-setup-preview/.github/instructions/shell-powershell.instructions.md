---
description: "PowerShell command safety and compatibility guidance for Terraform and Azure CLI usage."
applyTo: "**/*.ps1,**/*.tf,**/*.tfvars"
---

# PowerShell Command Safety

- Prefer explicit, PowerShell-compatible command forms.
- Use the call operator when invoking executables by full path.
- Avoid Linux-style redirects or tools that can change argument parsing unexpectedly.
- Keep Terraform command examples tested for PowerShell behavior.
- When command output is ambiguous, validate with an explicit follow-up check.
