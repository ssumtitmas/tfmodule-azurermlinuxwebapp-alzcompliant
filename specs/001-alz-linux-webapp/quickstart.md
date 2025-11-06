# Quickstart Guide: ALZ-Compliant Linux Web App

**Target Audience**: Platform engineers deploying Azure Linux Web Apps with ALZ compliance  
**Time Required**: 15-30 minutes  
**Prerequisites**: Azure subscription, Log Analytics workspace, Terraform 1.7+

## Overview

This guide demonstrates how to deploy a secure, ALZ-compliant Linux Web App using three common scenarios:
1. **Basic deployment** - Minimal configuration with secure defaults
2. **Diagnostics integration** - Full logging to Log Analytics workspace  
3. **Private ASE deployment** - Enterprise private connectivity

## Prerequisites

- Azure subscription with contributor access
- Log Analytics workspace (for diagnostic settings)
- Terraform >= 1.7.0 installed
- Azure CLI or service principal authentication configured

## Scenario 1: Basic Deployment

Deploy a simple web app with system-assigned managed identity and secure defaults.

### 1. Create Basic Configuration

```hcl
# examples/basic/main.tf
module "linux_web_app" {
  source = "../../modules/linux-webapp"

  workload_name                = "myapp"
  environment                  = "dev"
  location                     = "East US"
  resource_group_name          = "rg-myapp-dev-eastus-001"
  log_analytics_workspace_id   = "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"

  tags = {
    Environment = "Development"
    Owner       = "Platform Team"
    CostCenter  = "IT-001"
  }
}
```

### 2. Deploy

```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

### 3. Verify Deployment

```bash
# Check web app is running
az webapp show --name myapp-dev-eastus-001 --resource-group rg-myapp-dev-eastus-001

# Verify HTTPS-only and TLS 1.2+
az webapp config show --name myapp-dev-eastus-001 --resource-group rg-myapp-dev-eastus-001 --query "{httpsOnly:httpsOnly,minTlsVersion:minTlsVersion}"
```

**Expected Output**: `{"httpsOnly": true, "minTlsVersion": "1.2"}`

## Scenario 2: Diagnostics Integration

Deploy with comprehensive logging and monitoring configuration.

### 1. Enhanced Configuration

```hcl
# examples/diagnostics/main.tf
module "linux_web_app" {
  source = "../../modules/linux-webapp"

  workload_name                = "webapp"
  environment                  = "prod"
  location                     = "East US 2"
  resource_group_name          = "rg-webapp-prod-eastus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Production App Service Plan
  app_service_plan_sku = "P1v3"

  # Runtime configuration
  linux_fx_version = "NODE|18-lts"
  
  site_config = {
    always_on         = true
    health_check_path = "/health"
  }

  # Application settings
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18.17.0"
    "NODE_ENV"                     = "production"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = var.app_insights_key
  }

  # Enhanced diagnostic categories
  diagnostic_log_categories = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]

  tags = {
    Environment     = "Production"
    Owner          = "Application Team"
    CostCenter     = "LOB-001"
    Compliance     = "ALZ"
    BackupRequired = "true"
  }
}
```

### 2. Verify Logging

```bash
# Check diagnostic settings
az monitor diagnostic-settings list --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{app-name}"

# Query logs in Log Analytics
az monitor log-analytics query \
  --workspace "{workspace-id}" \
  --analytics-query "AppServiceHTTPLogs | where TimeGenerated > ago(1h) | limit 10"
```

## Scenario 3: Private ASE Deployment

Deploy in Azure App Service Environment v3 with private connectivity.

### 1. Private Configuration

```hcl
# examples/private-ase/main.tf
module "linux_web_app" {
  source = "../../modules/linux-webapp"

  workload_name                = "internalapp"
  environment                  = "prod"
  location                     = "West US 2"
  resource_group_name          = "rg-internal-prod-westus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Use existing ASEv3 App Service Plan
  app_service_plan_id = "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/serverfarms/{ase-plan-name}"

  # Corporate network access only
  access_restrictions = [
    {
      name                      = "Corporate-Network"
      priority                  = 100
      virtual_network_subnet_id = "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}"
      description              = "Allow access from corporate VNet"
    },
    {
      name        = "Management-IPs"
      priority    = 200
      ip_address  = "10.0.0.0/8"
      description = "Allow management from private IP ranges"
    }
  ]

  # User-assigned managed identity for specific permissions
  user_assigned_identity_ids = [
    "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity-name}"
  ]

  tags = {
    Environment = "Production"
    Owner       = "Security Team"
    Network     = "Private"
    Compliance  = "ALZ"
  }
}
```

### 2. Verify Private Access

```bash
# Test from corporate network (should succeed)
curl -I https://internalapp-prod-westus2-001.ase.internal.contoso.com

# Test from public internet (should fail - blocked by access restrictions)
curl -I https://internalapp-prod-westus2-001.azurewebsites.net
```

## Common Patterns

### Zero-Downtime Deployments

Add deployment slots for blue-green deployments:

```hcl
deployment_slots = {
  staging = {
    auto_swap_slot_name = "production"
    site_config = {
      always_on = true
    }
    app_settings = {
      "SLOT_NAME" = "staging"
    }
  }
}
```

### Multiple Environment Support

Use Terraform workspaces or variable files:

```hcl
# terraform.tfvars.dev
workload_name = "myapp"
environment   = "dev"
app_service_plan_sku = "B1"

# terraform.tfvars.prod  
workload_name = "myapp"
environment   = "prod"
app_service_plan_sku = "P2v3"
```

### Connection String Management

Securely reference Key Vault secrets:

```hcl
connection_strings = {
  "DefaultConnection" = {
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=${var.database_connection_secret_uri})"
  }
}
```

## Troubleshooting

### Common Issues

1. **Log Analytics Access Denied**
   - Verify workspace exists and is accessible
   - Check RBAC permissions for managed identity

2. **Access Restrictions Not Working**
   - Validate IP address format (CIDR notation)
   - Check subnet service endpoint configuration
   - Verify priority values (lower = higher priority)

3. **ASE Plan Compatibility**
   - Ensure App Service Plan is Linux-compatible
   - Verify ASE version supports required features

### Validation Commands

```bash
# Check ALZ compliance
terraform plan -var-file="terraform.tfvars" | grep -E "(https_only|minimum_tls_version|identity)"

# Verify resource naming
az resource list --resource-group "rg-myapp-dev-eastus-001" --query "[].name"

# Test managed identity
az webapp identity show --name "myapp-dev-eastus-001" --resource-group "rg-myapp-dev-eastus-001"
```

## Next Steps

- Review [Module Documentation](../../../docs/usage.md) for advanced configuration
- Explore [CI/CD Integration](../../../.github/workflows/ci.yml) for automated deployment
- Check [Security Best Practices](../../../docs/security.md) for production hardening

## Support

- **Issues**: Create GitHub issue with reproduction steps
- **Feature Requests**: Submit enhancement request with business justification
- **Security Concerns**: Follow responsible disclosure process