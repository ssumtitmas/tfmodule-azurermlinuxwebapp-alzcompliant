# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]
**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the Terraform module. The structure here is presented in advisory capacity 
  to guide the iteration process.
-->

**Terraform Version**: [e.g., >= 1.7.0 or NEEDS CLARIFICATION]  
**Provider Requirements**: [e.g., azurerm ~> 3.0, azuread ~> 2.0 or NEEDS CLARIFICATION]  
**Target Azure Services**: [e.g., App Service, Key Vault, Log Analytics or NEEDS CLARIFICATION]  
**Testing Framework**: [e.g., Terratest, terraform-compliance or NEEDS CLARIFICATION]  
**Target Environment**: [e.g., Azure Landing Zone, Enterprise environments or NEEDS CLARIFICATION]
**Module Type**: [single-service/multi-service - determines resource structure]  
**Performance Goals**: [domain-specific, e.g., provision <5min, support 1000 apps or NEEDS CLARIFICATION]  
**Constraints**: [domain-specific, e.g., ALZ compliance, specific regions, cost limits or NEEDS CLARIFICATION]  
**Scale/Scope**: [domain-specific, e.g., enterprise-grade, multi-tenant, specific workload sizes or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [ ] **Terraform Version Compliance**: Terraform 1.7+ required, azurerm provider pinned to stable major
- [ ] **ALZ Security Alignment**: HTTPS-only, TLS 1.2+, diagnostic settings, required tags, managed identity, network restrictions, naming standards
- [ ] **Input Validation**: All variables have type constraints and custom validation where applicable
- [ ] **Zero Secrets in Code**: No hardcoded secrets, sensitive variables marked appropriately
- [ ] **CI Gates**: fmt, validate, tflint, tfsec all configured and passing
- [ ] **Semantic Versioning**: Version strategy defined, conventional commits planned
- [ ] **Minimal Examples**: Example configurations are minimal and idempotent

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this Terraform module. Delete unused options and expand the chosen structure 
  with real resource files. The delivered plan must not include Option labels.
-->

```text
# Terraform Module Structure (DEFAULT)
├── main.tf              # Primary resource definitions
├── variables.tf         # Input variable declarations  
├── outputs.tf           # Output value definitions
├── versions.tf          # Provider version constraints
├── locals.tf            # Local value computations
├── data.tf              # Data source definitions
└── modules/             # Sub-modules (if needed)
    └── [submodule]/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf

examples/
├── basic/               # Minimal working example
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
├── complete/            # Full-featured example
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars.example
└── alz-compliant/       # ALZ-specific example
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars.example

tests/
├── integration/         # End-to-end tests with Terratest
├── validation/          # Input validation tests
└── fixtures/            # Test data and configurations

docs/
├── usage.md            # Usage documentation
├── inputs.md           # Generated input documentation  
├── outputs.md          # Generated output documentation
└── examples.md         # Example configurations
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
