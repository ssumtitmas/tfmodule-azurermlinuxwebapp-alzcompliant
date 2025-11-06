# Research: ALZ-Compliant Linux Web App Terraform Module

**Phase**: 0 - Outline & Research  
**Date**: 2025-11-06  
**Feature**: ALZ-Compliant Linux Web App Terraform Module

## Research Tasks

### Task 1: Testing Framework Selection

**Unknown**: Testing Framework - Terratest vs terraform-compliance vs native terraform test

**Research Context**: Need to determine the best testing approach for validating Terraform modules in CI/CD pipeline with ALZ compliance requirements.

**Decision**: Native Terraform testing with `terraform test` (Terraform 1.6+)

**Rationale**: 
- Built into Terraform 1.7+ (our minimum version requirement)
- No external dependencies or Go compilation required
- Integrates naturally with CI/CD pipelines
- Supports both unit tests (plan validation) and integration tests (apply/destroy)
- Can validate ALZ policy compliance through resource attribute assertions
- Faster execution than external frameworks

**Alternatives Considered**:
- **Terratest**: More powerful but requires Go environment, longer execution times, more complex CI setup
- **terraform-compliance**: BDD-style but limited to plan validation, cannot test actual deployment
- **Checkov/tfsec integration**: Good for security scanning but not comprehensive testing

**Implementation Impact**: 
- Add `terraform test` commands to CI pipeline
- Create test files alongside examples to validate deployment scenarios
- Use for validating ALZ compliance requirements

### Task 2: Azure Provider Version Selection

**Unknown**: Specific azurerm provider version constraint (~> X.Y)

**Research Context**: Need to pin to stable major version while ensuring compatibility with latest Azure features required for ALZ compliance.

**Decision**: azurerm ~> 3.0

**Rationale**:
- Version 3.x is the current stable major version
- Includes all Azure Landing Zone required features (managed identity, diagnostic settings, access restrictions)
- Wide enterprise adoption and proven stability
- Regular security updates within major version
- Breaking changes only occur between major versions

**Alternatives Considered**:
- **~> 4.0**: Too new, potential stability issues in enterprise environments
- **~> 2.0**: Missing some ALZ features, approaching end of support lifecycle
- **= 3.x.x**: Too restrictive, prevents security updates

**Implementation Impact**:
- Set `version = "~> 3.0"` in versions.tf
- Test against latest 3.x version in CI pipeline
- Document version compatibility in README

### Task 3: ALZ Naming Convention Standards

**Unknown**: Specific ALZ naming pattern implementation

**Research Context**: Azure Landing Zone prescribes specific naming conventions for compliance and governance.

**Decision**: Implement CAF (Cloud Adoption Framework) naming convention with configurable components

**Rationale**:
- Follows Microsoft's official Azure Landing Zone guidance
- Format: `{workload}-{environment}-{region}-{instance}`
- Supports organizational customization while maintaining compliance
- Enables consistent resource identification across Azure estate

**Pattern**: `{var.workload_name}-${var.environment}-${var.location_short}-${var.instance_id}`

**Components**:
- `workload_name`: Application or service identifier (required)
- `environment`: dev/test/prod/staging (required) 
- `location_short`: Azure region abbreviation (auto-derived from location)
- `instance_id`: Unique identifier within environment (default: "001")

**Implementation Impact**:
- Create locals.tf with naming logic
- Validate inputs for naming compliance
- Support both auto-generated and custom names

### Task 4: Required Log Analytics Categories

**Unknown**: Specific diagnostic log categories required for ALZ compliance

**Research Context**: ALZ policies mandate specific logging categories for monitoring and compliance.

**Decision**: Enable comprehensive logging with required ALZ categories

**Required Categories**:
- **AppServiceHTTPLogs**: HTTP access logs for security monitoring
- **AppServiceConsoleLogs**: Application console output for troubleshooting
- **AppServiceAppLogs**: Application-specific logs for operational monitoring
- **AppServiceAuditLogs**: Security and access audit trails
- **AppServiceIPSecAuditLogs**: IP security audit logs
- **AppServicePlatformLogs**: Platform-level operational logs

**Metrics**:
- **AllMetrics**: Performance and resource utilization metrics

**Implementation Impact**:
- Configure diagnostic settings for both web app and slots
- Make categories configurable with secure defaults
- Validate Log Analytics workspace accessibility

### Task 5: Access Restriction Implementation Patterns

**Unknown**: Best practice implementation for IP restrictions and ASEv3 integration

**Research Context**: Need flexible access control supporting IP allowlists, service endpoints, and private ASE scenarios.

**Decision**: Hierarchical access restriction model with validation

**Pattern**:
```hcl
ip_restriction {
  name                      = each.value.name
  ip_address               = each.value.ip_address
  virtual_network_subnet_id = each.value.subnet_id
  service_tag              = each.value.service_tag
  priority                 = each.value.priority
  action                   = "Allow"
}
```

**Access Modes**:
1. **Public with IP restrictions**: IP allowlist for corporate access
2. **Service endpoint**: VNet subnet access via service endpoints  
3. **Private ASE**: ASEv3 with no public access
4. **Hybrid**: Combination of IP and service endpoint restrictions

**Implementation Impact**:
- Variable structure for flexible restriction configuration
- Validation to prevent conflicting access patterns
- ASEv3 compatibility checks

## Technology Decisions Summary

| Component | Decision | Version/Pattern |
|-----------|----------|-----------------|
| Terraform | Native testing | >= 1.7.0 |
| Provider | azurerm | ~> 3.0 |
| Naming | CAF standard | `{workload}-{env}-{region}-{instance}` |
| Logging | Comprehensive ALZ | 6 categories + metrics |
| Access Control | Hierarchical restrictions | IP/subnet/service tag support |

## Next Phase

All technical unknowns resolved. Ready to proceed to Phase 1 design with:
- Clear technology stack and constraints
- Defined naming and logging standards  
- Access control implementation patterns
- Testing strategy aligned with Terraform 1.7+ capabilities