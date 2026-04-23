---
description: "Guidance for Azure AI Foundry account and connection resources managed through azapi."
applyTo: "code/main.tf"
---

# Azure Foundry Connections (AzAPI)

- Keep API versions deliberate and consistent; validate payload structure against the selected API version.
- For connection resources, ensure required fields exist for the chosen auth type.
- For AccessKey auth, ensure required credentials and metadata fields are populated.
- Keep Foundry account network ACL intent aligned with private endpoint architecture.
- When fixing API validation errors, preserve existing architecture and change only the minimum required fields.
- Clearly describe any schema-driven changes that affect deployment behavior.
