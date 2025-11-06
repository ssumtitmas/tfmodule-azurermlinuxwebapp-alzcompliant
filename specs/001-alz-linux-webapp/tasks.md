# Tasks: ALZ-Compliant Linux Web App Terraform Module

**Input**: Design documents from `/specs/001-alz-linux-webapp/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are not explicitly requested in the feature specification, so test tasks are not included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Terraform Module**: `modules/linux-webapp/` with `.tf` files
- **Examples**: `examples/[scenario]/` with own `.tf` files
- **CI/CD**: `.github/workflows/` for automation
- **Documentation**: Root-level README.md and docs/

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Terraform module initialization and basic structure

- [x] T001 Create module directory structure at modules/linux-webapp/
- [x] T002 Create examples directory structure with basic/, diagnostics/, private-ase/ subdirectories
- [x] T003 Create .github/workflows/ directory for CI/CD automation
- [x] T004 [P] Initialize .gitignore file with Terraform and agent folder exclusions
- [x] T005 [P] Create docs/ directory for documentation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core module infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T006 Create versions.tf with Terraform >= 1.7.0 and azurerm ~> 3.0 constraints in modules/linux-webapp/versions.tf
- [x] T007 [P] Create variables.tf with base input variable declarations in modules/linux-webapp/variables.tf
- [x] T008 [P] Create locals.tf with ALZ naming convention calculations in modules/linux-webapp/locals.tf
- [x] T009 [P] Create outputs.tf with base output structure in modules/linux-webapp/outputs.tf
- [x] T010 Initialize main.tf with provider configuration and data sources in modules/linux-webapp/main.tf

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Deploy Basic ALZ-Compliant Web App (Priority: P1) 🎯 MVP

**Goal**: Deploy secure Linux web app with ALZ compliance using minimal configuration

**Independent Test**: Can be fully tested by running terraform apply with minimal inputs and verifying ALZ security baselines

### Implementation for User Story 1

- [x] T011 [P] [US1] Define core input variables in modules/linux-webapp/variables.tf (workload_name, environment, location, resource_group_name, log_analytics_workspace_id)
- [x] T012 [P] [US1] Add input validation rules for core variables in modules/linux-webapp/variables.tf
- [x] T013 [P] [US1] Add optional App Service Plan variables in modules/linux-webapp/variables.tf (app_service_plan_id, app_service_plan_sku)
- [x] T014 [US1] Implement conditional App Service Plan creation logic in modules/linux-webapp/main.tf
- [x] T015 [US1] Implement azurerm_linux_web_app resource with ALZ-compliant defaults in modules/linux-webapp/main.tf
- [x] T016 [US1] Configure system-assigned managed identity block in modules/linux-webapp/main.tf
- [x] T017 [US1] Enforce HTTPS-only and TLS 1.2+ settings in modules/linux-webapp/main.tf
- [x] T018 [US1] Configure site_config block with secure defaults in modules/linux-webapp/main.tf
- [x] T019 [US1] Implement diagnostic settings to Log Analytics workspace in modules/linux-webapp/main.tf
- [x] T020 [US1] Define core outputs (web_app_id, system_assigned_identity, app_service_plan_id) in modules/linux-webapp/outputs.tf
- [x] T021 [US1] Create basic example configuration in examples/basic/main.tf
- [x] T022 [P] [US1] Create variables.tf for basic example in examples/basic/variables.tf
- [x] T023 [P] [US1] Create terraform.tfvars.example for basic example in examples/basic/terraform.tfvars.example

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Configure Access Restrictions (Priority: P2)

**Goal**: Control network access using IP allowlists, service endpoints, or private ASEv3 connectivity

**Independent Test**: Can be tested by deploying with different access restriction configurations and verifying network connectivity rules

### Implementation for User Story 2

- [x] T024 [P] [US2] Add access_restrictions variable with validation in modules/linux-webapp/variables.tf
- [x] T025 [P] [US2] Add user_assigned_identity_ids variable in modules/linux-webapp/variables.tf
- [x] T026 [US2] Implement user-assigned managed identity support in modules/linux-webapp/main.tf
- [x] T027 [US2] Implement ip_restriction blocks using for_each in modules/linux-webapp/main.tf
- [x] T028 [US2] Add access restriction validation logic in modules/linux-webapp/main.tf
- [x] T029 [US2] Add user-assigned identity outputs in modules/linux-webapp/outputs.tf
- [ ] T030 [US2] Create diagnostics example with Log Analytics integration in examples/diagnostics/main.tf
- [ ] T031 [P] [US2] Create variables.tf for diagnostics example in examples/diagnostics/variables.tf
- [x] T032 [P] [US2] Create terraform.tfvars.example for diagnostics example in examples/diagnostics/terraform.tfvars.example
- [x] T033 [P] [US2] Create private-ase example main.tf in examples/private-ase/main.tf with access restrictions
- [x] T034 [P] [US2] Create private-ase example variables.tf in examples/private-ase/variables.tf
- [x] T035 [P] [US2] Create terraform.tfvars.example for private-ase example in examples/private-ase/terraform.tfvars.example

**Checkpoint**: Access restrictions and identity management fully implemented and testable

---

## Phase 5: User Story 3 - Manage Deployment Slots (Priority: P3)

**Goal**: Support zero-downtime deployments using deployment slots with production parity configuration

**Independent Test**: Can be tested by creating deployment slots and performing slot swaps while monitoring availability

### Implementation for User Story 3

- [x] T036 [P] [US3] Add deployment_slots variable with nested configuration in modules/linux-webapp/variables.tf
- [x] T037 [P] [US3] Add site_config, app_settings, connection_strings variables in modules/linux-webapp/variables.tf
- [x] T038 [US3] Implement azurerm_linux_web_app_slot resources using for_each in modules/linux-webapp/main.tf
- [x] T039 [US3] Configure slot security settings to inherit from main app in modules/linux-webapp/main.tf
- [x] T040 [US3] Implement diagnostic settings for deployment slots in modules/linux-webapp/main.tf
- [x] T041 [US3] Add deployment slot outputs in modules/linux-webapp/outputs.tf
- [x] T042 [US3] Add connection string and app settings support to main web app in modules/linux-webapp/main.tf
- [x] T043 [US3] Enhance examples with deployment slot configurations in examples/*/main.tf

**Checkpoint**: Deployment slots fully implemented with zero-downtime capabilities

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Documentation, CI/CD, and final quality assurance

- [ ] T044 [P] Create CI workflow with quality gates in .github/workflows/ci.yml
- [ ] T045 [P] Add release workflow for tagging and changelog in .github/workflows/release.yml
- [ ] T046 [P] Create comprehensive README.md with usage examples and inputs/outputs tables
- [ ] T047 [P] Add module documentation in docs/usage.md
- [ ] T048 [P] Create CHANGELOG.md template
- [ ] T049 [P] Add pre-commit configuration in .pre-commit-config.yaml
- [ ] T050 [P] Create terraform-docs configuration for auto-generated documentation
- [ ] T051 Run terraform fmt across all module and example files
- [ ] T052 Run terraform validate on module and all examples
- [ ] T053 Run tflint with ALZ-specific rules on module files
- [ ] T054 Run tfsec security scanning on module and examples
- [ ] T055 Validate example terraform plans can be generated successfully
- [ ] T056 Add README badges for CI status, security scanning, and latest release

---

## Dependencies

### User Story Completion Order

```text
Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1) → Phase 4 (US2) → Phase 5 (US3) → Phase 6 (Polish)
```

### Critical Dependencies

- **T006-T010** (Foundation) MUST complete before any user story work
- **T015** (Web App Resource) blocks all subsequent web app configuration tasks
- **T019** (Diagnostic Settings) required for ALZ compliance validation
- **T044-T046** (CI/CD and Documentation) should wait until core functionality is complete

### Parallel Execution Opportunities

**Phase 2 Foundational**:
- T007, T008, T009 can run in parallel (different files)

**User Story 1**:
- T011, T012, T013 can run in parallel (same file, different sections)
- T022, T023 can run in parallel with T020, T021 (different directories)

**User Story 2**:
- T024, T025 can run in parallel (same file, different variables)
- T031, T032, T034, T035 can run in parallel (different example directories)

**Polish Phase**:
- T044, T045, T046, T047, T048, T049, T050 can all run in parallel (different files/directories)

## Implementation Strategy

### MVP Scope (Immediate Value)
- **Phase 1-3 only**: Basic ALZ-compliant web app deployment
- Delivers core value: secure web app with managed identity, HTTPS-only, diagnostic logging
- Can be used immediately for production workloads requiring ALZ compliance

### Incremental Delivery
1. **MVP**: User Story 1 (T001-T023) - Basic secure deployment
2. **Enhanced Security**: User Story 2 (T024-T035) - Network access controls
3. **Production Ready**: User Story 3 (T036-T043) - Zero-downtime deployments
4. **Enterprise Ready**: Polish phase (T044-T056) - Full CI/CD and documentation

### Quality Gates
- Each user story phase ends with independent testing capability
- Constitution compliance verified at each phase
- All examples must deploy and destroy cleanly
- Security scanning must pass before phase completion

## Summary

- **Total Tasks**: 56
- **User Story 1 (P1)**: 13 tasks - Core ALZ-compliant deployment
- **User Story 2 (P2)**: 12 tasks - Access restrictions and identity management  
- **User Story 3 (P3)**: 8 tasks - Deployment slots and zero-downtime updates
- **Infrastructure**: 23 tasks - Setup, foundation, and polish phases
- **Parallel Opportunities**: 15+ tasks can run simultaneously in different phases
- **MVP Delivery**: 23 tasks (Phases 1-3) provide immediate production value
- **Independent Testing**: Each user story can be validated independently through terraform apply/destroy cycles