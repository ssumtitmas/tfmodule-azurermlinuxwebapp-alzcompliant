# Azure Linux Web App - ALZ Compliant Terraform Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

A production-ready Terraform module that deploys an Azure Linux Web App with secure defaults and full alignment to Azure Landing Zone (ALZ) policies. This module provides enterprise-grade security, monitoring, and operational capabilities out of the box.

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Usage Examples](#-usage-examples)
  - [External-Facing Deployment](#external-facing-deployment)
  - [Internal-Facing Deployment](#internal-facing-deployment)
- [Module Configuration](#-module-configuration)
- [Inputs](#-inputs)
- [Outputs](#-outputs)
- [Examples](#-examples)
- [ALZ Compliance](#-alz-compliance)
- [Requirements](#-requirements)

## 🚀 Features

### Core Capabilities
- **ALZ Policy Compliant**: Automatically configured to meet Azure Landing Zone security requirements
- **Secure by Default**: HTTPS-only, TLS 1.2+, managed identity enabled
- **Private Endpoint Support**: Deploy internal-only apps with Azure Private Link
- **Zero-Downtime Deployments**: Built-in deployment slot support for production workloads
- **Comprehensive Monitoring**: Integrated diagnostic settings and Log Analytics workspace support
- **Network Security**: Configurable IP restrictions and virtual network integration
- **Identity Management**: System-assigned and user-assigned managed identity support

### Security Features
- ✅ HTTPS-only traffic enforcement
- ✅ Minimum TLS 1.2 requirement
- ✅ Managed identity by default
- ✅ Diagnostic logging to Log Analytics
- ✅ Network access restrictions
- ✅ Private endpoint for internal deployments
- ✅ Public network access control
- ✅ ALZ naming conventions
- ✅ Required ALZ compliance tags

### Operational Features
- 🔄 Deployment slots for zero-downtime updates
- 📊 Comprehensive diagnostic settings
- 🏷️ Automatic ALZ-compliant resource naming
- 📈 Built-in health checks and monitoring
- 🔒 Connection string and app settings management

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.7.0
- Azure CLI or Azure PowerShell
- Log Analytics workspace (for ALZ compliance)
- Resource group

### Basic Usage

```hcl
module "web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant?ref=v1.0.0"

  # ========================================
  # REQUIRED VARIABLES
  # ========================================
  workload_name       = "myapp"              # REQUIRED: Workload name for ALZ naming
  environment         = "prod"               # REQUIRED: Environment (dev, test, staging, prod)
  location            = "East US 2"          # REQUIRED: Azure region
  resource_group_name = "rg-myapp-prod-eastus2-001"  # REQUIRED: Resource group name
  
  # REQUIRED: Log Analytics workspace for ALZ compliance
  log_analytics_workspace_id = "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"

  # ========================================
  # OPTIONAL VARIABLES (with defaults)
  # ========================================
  # Runtime configuration (defaults to NODE|18-lts)
  linux_fx_version = "NODE|18-lts"

  # ALZ compliance tags (optional - defaults provided)
  tags = {
    Environment = "Production"
    Owner      = "Application Team"
    CostCenter = "APP-001"
    Compliance = "ALZ"
  }
}
```

## 📚 Usage Examples

### External-Facing Deployment

Public-facing deployment with public network access enabled:

```hcl
module "external_web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant?ref=v1.0.0"

  # REQUIRED: Core configuration
  workload_name                = "webapp"
  environment                  = "prod"
  location                     = "East US 2"
  resource_group_name          = "rg-webapp-prod-eastus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # OPTIONAL: Premium tier for production
  app_service_plan_sku = "P1v3"
  
  # OPTIONAL: Runtime configuration
  linux_fx_version = "NODE|18-lts"

  # Network configuration - PUBLIC ACCESS ENABLED
  public_network_access_enabled = true
  
  # No private endpoint for external deployment
  private_endpoint = {
    enabled = false
  }

  # OPTIONAL: Site configuration
  site_config = {
    always_on              = true
    health_check_path      = "/health"
    websockets_enabled     = false
    client_affinity_enabled = false
  }

  # OPTIONAL: Application settings
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION"     = "18.17.0"
    "NODE_ENV"                         = "production"
    "WEBSITE_RUN_FROM_PACKAGE"        = "1"
  }

  # Production tags
  tags = {
    Environment        = "Production"
    Owner             = "Platform Team"
    CostCenter        = "IT-001"
    Compliance        = "ALZ"
    DataClassification = "Public"
    NetworkType       = "External"
  }
}
```

### Internal-Facing Deployment

Private deployment with public access disabled and private endpoint:

```hcl
module "internal_web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant?ref=v1.0.0"

  # REQUIRED: Core configuration
  workload_name                = "webapp"
  environment                  = "prod"
  location                     = "East US 2"
  resource_group_name          = "rg-webapp-prod-eastus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # OPTIONAL: Premium tier required for private endpoints
  app_service_plan_sku = "P1v3"
  
  # OPTIONAL: Runtime configuration
  linux_fx_version = "NODE|18-lts"

  # Network configuration - PUBLIC ACCESS DISABLED
  public_network_access_enabled = false

  # Private endpoint configuration for internal access
  private_endpoint = {
    enabled                        = true
    subnet_id                      = var.private_endpoint_subnet_id
    private_dns_zone_ids           = [var.private_dns_zone_id]
    private_service_connection_name = "webapp-private-connection"
  }

  # OPTIONAL: Site configuration
  site_config = {
    always_on              = true
    health_check_path      = "/health"
    websockets_enabled     = false
    client_affinity_enabled = false
  }

  # OPTIONAL: Application settings
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION"     = "18.17.0"
    "NODE_ENV"                         = "production"
    "WEBSITE_RUN_FROM_PACKAGE"        = "1"
  }

  # Production tags
  tags = {
    Environment        = "Production"
    Owner             = "Platform Team"
    CostCenter        = "IT-001"
    Compliance        = "ALZ"
    DataClassification = "Internal"
    NetworkType       = "Private"
  }
}
```

## ⚙️ Module Configuration

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| `workload_name` | The workload name for ALZ naming convention | `string` |
| `environment` | The environment (e.g., dev, test, prod) | `string` |
| `location` | The Azure region for resources | `string` |
| `resource_group_name` | Name of the resource group | `string` |
| `log_analytics_workspace_id` | Log Analytics workspace resource ID | `string` |

### Optional Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `app_service_plan_sku` | App Service Plan SKU | `string` | `"B1"` |
| `linux_fx_version` | Linux runtime stack | `string` | `"NODE|18-lts"` |
| `access_restrictions` | IP access restrictions | `list(object)` | `[]` |
| `deployment_slots` | Deployment slot configurations | `map(object)` | `{}` |
| `user_assigned_identity_ids` | User-assigned managed identity IDs | `list(string)` | `[]` |

## 📤 Outputs

| Name | Description |
|------|-------------|
| `id` | Resource ID of the Linux Web App |
| `default_hostname` | The default hostname of the web app |
| `system_assigned_identity` | System-assigned managed identity details |
| `user_assigned_identities` | User-assigned managed identity details |
| `deployment_slots` | Deployment slot details |

## � Required vs Optional Variables

### Required Variables (Must Provide)
These variables **must** be specified - Terraform will fail without them:
- `workload_name` - Workload name for ALZ naming (2-10 chars, lowercase alphanumeric)
- `environment` - Environment name (must be: dev, test, staging, or prod)
- `location` - Azure region for deployment
- `resource_group_name` - Name of the resource group
- `log_analytics_workspace_id` - Log Analytics workspace resource ID for ALZ compliance

### Optional Variables (Have Defaults)
These variables are **optional** - they have sensible defaults:
- `app_service_plan_sku` - Default: `"B1"` (Basic tier)
- `linux_fx_version` - Default: `"NODE|18-lts"`
- `public_network_access_enabled` - Default: `true` (public access enabled)
- `private_endpoint` - Default: `{ enabled = false }` (no private endpoint)
- `access_restrictions` - Default: `[]` (no IP restrictions)
- `app_settings` - Default: `{}` (no custom app settings)
- `user_assigned_identity_ids` - Default: `[]` (system-assigned identity only)
- `tags` - Default: `{}` (no custom tags)

**💡 Tip**: Only override optional variables when you need to change the default behavior!

## 📁 Examples

This repository includes two deployment examples:

- **[External-Facing](./examples/external-facing/)**: Public-facing deployment with public network access enabled
- **[Internal-Facing](./examples/internal-facing/)**: Private deployment with public access disabled and private endpoint enabled

Each example includes:
- Complete Terraform configuration
- Variable definitions with validation
- Example `terraform.tfvars.example` file

## 🔒 ALZ Compliance

This module automatically ensures compliance with Azure Landing Zone policies:

### Security Requirements
- ✅ HTTPS-only traffic
- ✅ Minimum TLS 1.2
- ✅ Managed identity enabled
- ✅ Diagnostic settings configured
- ✅ Network restrictions supported

### Naming Conventions
- Resources follow ALZ naming patterns: `{type}-{workload}-{environment}-{region}-{instance}`
- Example: `app-webapp-prod-eastus2-001`

### Required Tags
- Environment
- Workload
- ManagedBy
- Module

## 📋 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.0 |
| azurerm | ~> 3.0 |

### Azure Resources
- Resource Group (existing)
- Log Analytics Workspace (existing)
- Virtual Network/Subnet (optional, for network restrictions)

## 🆘 Support

For issues and questions:
- Create an [Issue](https://github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant/issues)
- Check the [Examples](./examples/) for common use cases
- Review the [ALZ documentation](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)

---

