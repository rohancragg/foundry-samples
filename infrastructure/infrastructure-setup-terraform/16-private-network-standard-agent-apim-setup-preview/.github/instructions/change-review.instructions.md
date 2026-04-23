---
description: "Review checklist for high-impact Terraform changes in this infrastructure stack."
applyTo: "code/main.tf,code/variables.tf,code/versions.tf,code/providers.tf"
---

# Change Review Checklist

Before approving or applying significant changes, check:

- Does this change alter location, SKU, naming, or subnet ranges?
- Does the plan include replacements for VNet, APIM, storage, search, cosmos, or app gateway?
- Are public access settings changing from private defaults?
- Are backend/state settings changing safely with reconfigure and migration steps?
- Are there new secrets or sensitive outputs introduced?
- Is rollback path clear and documented for temporary access changes?

If any answer is yes, provide a blast-radius summary before apply.
