<!--
Sync Impact Report:
- Version change: Initial → 1.0.0
- New constitution creation with 7 core principles
- Added sections: Security & Compliance, Quality Assurance
- Templates requiring updates: ✅ updated plan-template.md, spec-template.md, tasks-template.md
- Follow-up TODOs: None
-->

# ALZ-Compliant Linux Web App Terraform Module Constitution

## Core Principles

### I. Terraform Version Compliance
**MUST** use Terraform 1.7+ with azurerm provider pinned to stable major version.
Version constraints MUST be explicit in `versions.tf`. Breaking changes in provider 
versions require constitution amendment and impact assessment.

**Rationale**: Ensures reproducible deployments and prevents breaking changes from 
automatic provider updates while maintaining access to modern Terraform features.

### II. ALZ Security Alignment (NON-NEGOTIABLE)
**MUST** enforce Azure Landing Zone security baselines: HTTPS-only endpoints, TLS 1.2+ 
minimum, diagnostic settings routing to Log Analytics workspace, required tags compliance, 
managed identity by default, network access restrictions, ALZ naming standards.

**Rationale**: Ensures enterprise security compliance and consistency with Azure Landing 
Zone patterns for governance and security.

### III. Input Validation & Type Safety
**MUST** define explicit type constraints for all variables with custom validation 
blocks where business logic applies. No dynamic typing without explicit justification.
Validation errors MUST provide clear guidance to users.

**Rationale**: Prevents runtime errors, improves user experience, and ensures 
infrastructure predictability through compile-time validation.

### IV. Zero Secrets in Code (NON-NEGOTIABLE)
**MUST** never store secrets, keys, or sensitive data in Terraform code. 
**MUST** use Azure Key Vault references or pipeline secret management.
Sensitive variables MUST be marked with `sensitive = true`.

**Rationale**: Prevents credential exposure in version control, state files, 
and logs while maintaining security best practices.

### V. Continuous Integration Gates
**MUST** pass all CI gates before merge: `terraform fmt`, `terraform validate`, 
`tflint`, `tfsec`. Gate failures block deployment. Custom rules MAY be added 
but core gates are NON-NEGOTIABLE.

**Rationale**: Ensures code quality, security compliance, and consistent formatting 
across all contributions while catching issues early in development cycle.

### VI. Semantic Versioning & Release Management
**MUST** follow semantic versioning (MAJOR.MINOR.PATCH) with conventional commits.
**MUST** maintain CHANGELOG.md with breaking changes clearly documented.
Release process MUST be automated and idempotent.

**Rationale**: Enables predictable upgrade paths for consumers and clear communication 
of breaking changes while maintaining professional release practices.

### VII. Minimal Example Environments
**MUST** provide example configurations that are minimal, focused, and idempotent.
Examples MUST demonstrate core functionality without unnecessary complexity.
All examples MUST be tested and deployable.

**Rationale**: Reduces cognitive load for new users while providing working 
reference implementations that serve as both documentation and validation.

## Security & Compliance Requirements

**Azure Landing Zone Alignment**: All resources MUST comply with ALZ policies including 
diagnostic settings, naming conventions, tagging requirements, and network security rules.

**Threat Modeling**: Security controls MUST address OWASP Top 10 and Azure Security 
Benchmark requirements. TLS 1.2+ enforcement is mandatory for all endpoints.

**Monitoring**: Diagnostic settings MUST route to centralized Log Analytics workspace 
with appropriate retention policies and alert rules configured.

## Quality Assurance Standards

**Static Analysis**: tflint and tfsec MUST pass with zero violations. Custom rules 
MAY extend but never override core security checks.

**Code Review**: All changes require peer review with focus on security implications, 
ALZ compliance, and breaking change assessment.

**Testing Strategy**: Integration tests MUST validate deployed infrastructure meets 
security baselines. Unit tests MUST cover input validation logic.

## Governance

Constitution supersedes all other development practices. All pull requests MUST verify 
compliance with constitutional principles. Complexity additions require explicit 
justification and impact assessment.

Amendments require documentation of rationale, migration plan for existing consumers, 
and approval from module maintainers. Breaking changes require MAJOR version increment.

**Version**: 1.0.0 | **Ratified**: 2025-11-06 | **Last Amended**: 2025-11-06
