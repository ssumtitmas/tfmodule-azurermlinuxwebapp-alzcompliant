# Azure Linux Web App - ALZ Compliant Terraform Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

A production-ready Terraform module that deploys an Azure Linux Web App with secure defaults and full alignment to Azure Landing Zone (ALZ) policies. This module provides enterprise-grade security, monitoring, and operational capabilities out of the box.

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Usage Examples](#-usage-examples)
  - [Basic Deployment](#basic-deployment)
  - [Enhanced Monitoring](#enhanced-monitoring)
  - [Private Access Restrictions](#private-access-restrictions)
  - [Remote Module Usage](#remote-module-usage)
- [Module Configuration](#-module-configuration)
- [Inputs](#-inputs)
- [Outputs](#-outputs)
- [Examples](#-examples)
- [ALZ Compliance](#-alz-compliance)
- [Requirements](#-requirements)
- [Contributing](#-contributing)

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
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant//modules/linux-webapp?ref=v1.0.0"

  # Core configuration
  workload_name       = "myapp"
  environment         = "prod"
  location            = "East US 2"
  resource_group_name = "rg-myapp-prod-eastus2-001"

  # ALZ compliance requirement
  log_analytics_workspace_id = "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"

  # Runtime configuration
  linux_fx_version = "NODE|18-lts"

  # ALZ compliance tags
  tags = {
    Environment = "Production"
    Owner      = "Application Team"
    CostCenter = "APP-001"
    Compliance = "ALZ"
  }
}
```

## 📚 Usage Examples

### Basic Deployment

The simplest deployment for development or testing environments:

```hcl
module "basic_web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant//modules/linux-webapp?ref=v1.0.0"

  workload_name                = "webapp"
  environment                  = "dev"
  location                     = "East US 2"
  resource_group_name          = "rg-webapp-dev-eastus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Basic runtime configuration
  linux_fx_version = "PYTHON|3.11"
  app_service_plan_sku = "B1"

  # Development tags
  tags = {
    Environment = "Development"
    Owner      = "Dev Team"
    CostCenter = "DEV-001"
    Compliance = "ALZ"
  }
}
```

### Enhanced Monitoring

Production deployment with comprehensive monitoring and custom app settings:

```hcl
module "production_web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant//modules/linux-webapp?ref=v1.0.0"

  workload_name                = "webapp"
  environment                  = "prod"
  location                     = "East US 2"
  resource_group_name          = "rg-webapp-prod-eastus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Production App Service Plan
  app_service_plan_sku = "P2v3"

  # Runtime configuration
  linux_fx_version = "NODE|18-lts"

  # Enhanced site configuration
  site_config = {
    always_on               = true
    health_check_path      = "/health"
    health_check_grace_period = 600
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    worker_count           = 2
  }

  # Application settings
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18.17.0"
    "NODE_ENV"                     = "production"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS" = "30"
    "APPINSIGHTS_INSTRUMENTATIONKEY" = var.app_insights_key
  }

  # Full diagnostic logging
  diagnostic_log_categories = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]

  # Deployment slot for staging
  deployment_slots = {
    staging = {
      site_config = {
        always_on           = true
        health_check_path   = "/health"
        minimum_tls_version = "1.2"
      }
      app_settings = {
        "NODE_ENV"  = "staging"
        "SLOT_NAME" = "staging"
      }
    }
  }

  # Production tags
  tags = {
    Environment     = "Production"
    Owner          = "Application Team"
    CostCenter     = "APP-001"
    Compliance     = "ALZ"
    BackupRequired = "true"
  }
}
```

### Private Access Restrictions

Secure deployment with network access controls:

```hcl
module "secure_web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant//modules/linux-webapp?ref=v1.0.0"

  workload_name                = "webapp"
  environment                  = "prod"
  location                     = "East US 2"
  resource_group_name          = "rg-webapp-prod-eastus2-001"
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Premium tier for private access
  app_service_plan_sku = "P2v3"
  linux_fx_version = "DOTNETCORE|8.0"

  # Network access restrictions
  access_restrictions = [
    {
      name                      = "AllowCorporateVNet"
      priority                  = 100
      action                   = "Allow"
      virtual_network_subnet_id = var.app_subnet_id
      description              = "Allow access from application subnet"
    },
    {
      name        = "AllowJumpbox"
      priority    = 200
      action      = "Allow"
      ip_address  = "10.0.1.100/32"
      description = "Allow access from jumpbox"
    },
    {
      name        = "DenyInternet"
      priority    = 300
      action      = "Deny"
      ip_address  = "0.0.0.0/0"
      description = "Deny all other access"
    }
  ]

  # User-assigned managed identity
  user_assigned_identity_ids = [
    var.user_assigned_identity_id
  ]

  # Security-focused tags
  tags = {
    Environment        = "Production"
    Owner             = "Security Team"
    CostCenter        = "SEC-001"
    Compliance        = "ALZ"
    DataClassification = "Confidential"
    SecurityLevel     = "High"
  }
}
```

### Remote Module Usage

Here's how to use this module in your service's Terraform configuration:

```hcl
# terraform/main.tf
terraform {
  required_version = ">= 1.7.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    # Configure your backend here
  }
}

provider "azurerm" {
  features {}
}

# Data sources for existing resources
data "azurerm_log_analytics_workspace" "main" {
  name                = "law-shared-prod-eastus2-001"
  resource_group_name = "rg-shared-prod-eastus2-001"
}

data "azurerm_subnet" "app" {
  name                 = "snet-app-prod-eastus2-001"
  virtual_network_name = "vnet-shared-prod-eastus2-001"
  resource_group_name  = "rg-network-prod-eastus2-001"
}

# Your service's web application
module "my_service_web_app" {
  source = "github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant//modules/linux-webapp?ref=v1.0.0"

  # Service-specific configuration
  workload_name       = "myservice"
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name

  # ALZ compliance
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id

  # Application configuration
  linux_fx_version     = "NODE|18-lts"
  app_service_plan_sku = var.environment == "prod" ? "P2v3" : "B2"

  # Runtime configuration
  site_config = {
    always_on               = var.environment == "prod" ? true : false
    health_check_path      = "/api/health"
    minimum_tls_version    = "1.2"
    http2_enabled          = true
    ftps_state            = "Disabled"
  }

  # Environment-specific app settings
  app_settings = merge(
    {
      "NODE_ENV"                        = var.environment
      "WEBSITE_NODE_DEFAULT_VERSION"    = "18.17.0"
      "PORT"                           = "8080"
    },
    var.additional_app_settings
  )

  # Network security (production only)
  access_restrictions = var.environment == "prod" ? [
    {
      name                      = "AllowAppSubnet"
      priority                  = 100
      action                   = "Allow"
      virtual_network_subnet_id = data.azurerm_subnet.app.id
      description              = "Allow access from app subnet"
    }
  ] : []

  # Production deployment slots
  deployment_slots = var.environment == "prod" ? {
    staging = {
      site_config = {
        always_on           = true
        health_check_path   = "/api/health"
        minimum_tls_version = "1.2"
      }
      app_settings = {
        "NODE_ENV"  = "staging"
        "SLOT_NAME" = "staging"
      }
    }
  } : {}

  # Service tags
  tags = {
    Environment = var.environment
    Service    = "my-service"
    Owner      = "My Team"
    CostCenter = "MYTEAM-001"
    Compliance = "ALZ"
  }
}

# Output important values for other resources
output "web_app_url" {
  description = "The default URL of the web app"
  value       = module.my_service_web_app.default_hostname
}

output "web_app_identity" {
  description = "The system-assigned managed identity"
  value       = module.my_service_web_app.system_assigned_identity
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

## 📁 Examples

This repository includes four comprehensive examples:

- **[Basic](./examples/basic/)**: Minimal ALZ-compliant deployment
- **[Diagnostics](./examples/diagnostics/)**: Enhanced monitoring and logging
- **[Internal](./examples/internal/)**: Private endpoint deployment with public access disabled
- **[Private ASE](./examples/private-ase/)**: Private access with network restrictions

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

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `terraform validate` and `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Create an [Issue](https://github.com/ssumtitmas/tfmodule-azurermlinuxwebapp-alzcompliant/issues)
- Check the [Examples](./examples/) for common use cases
- Review the [ALZ documentation](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)

---

Made with ❤️ for Azure Landing Zone compliance
