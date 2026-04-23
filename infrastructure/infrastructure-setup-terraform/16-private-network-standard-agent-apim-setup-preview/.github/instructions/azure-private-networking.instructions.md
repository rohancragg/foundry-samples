---
description: "Private networking guardrails for Azure resources in this Terraform solution."
applyTo: "code/main.tf,code/variables.tf,code/example.tfvars"
---

# Azure Private Networking Guardrails

- Default posture is private-only for data plane access.
- Do not enable public network access unless explicitly requested.
- For temporary public administration, prefer the smallest scope and include rollback steps.
- Keep private endpoints, DNS zones, and VNet links consistent with service connectivity.
- For Storage and Foundry ACL changes, consider both top-level public access flags and network rules.
- Treat APIM Internal mode as an architectural choice; do not imply it can be made public by a single toggle.
- When suggesting temporary access, include a clear time-box and revert plan.
