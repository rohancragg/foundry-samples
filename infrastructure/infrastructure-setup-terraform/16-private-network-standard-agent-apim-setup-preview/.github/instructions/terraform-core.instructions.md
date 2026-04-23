---
description: "Terraform authoring standards for this private Azure Foundry infrastructure. Use when editing Terraform resources, variables, and outputs."
applyTo: "code/**/*.tf"
---

# Terraform Core Standards

- Keep changes minimal, idempotent, and easy to review.
- Prefer variable-driven values over hardcoded constants.
- Preserve existing naming conventions and random suffix strategy.
- Avoid changing resource identities (name, location, SKU, subnet ranges) unless explicitly requested.
- If a change may force replacement, state that clearly before proposing apply.
- Keep provider and resource arguments compatible with current provider versions in this repo.
- Do not remove lifecycle guards unless specifically requested.
- Keep outputs useful for operations but avoid exposing secrets.
- When generating Terraform code, always use the Terraform MCP Server to fetch real-time provider documentation and registry data. Do not rely on training data for provider information.

## Comments and Documentation
- Use `#` for single-line comments and `/* */` for multi-line comments
- Write self-documenting code; use comments only to clarify complexity
- Add comments above resource blocks to explain non-obvious business logic

