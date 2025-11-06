# Module Interface Contract

**Module**: `modules/linux-webapp`  
**Version**: 1.0.0  
**Provider**: azurerm ~> 3.0

## Input Variables

### Required Inputs

```hcl
variable "workload_name" {
  description = "Name of the workload/application for ALZ naming convention"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{2,10}$", var.workload_name))
    error_message = "Workload name must be 2-10 characters, lowercase alphanumeric with hyphens only."
  }
}

variable "environment" {
  description = "Environment name for ALZ naming convention"
  type        = string
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group for deployment"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of Log Analytics workspace for diagnostic settings"
  type        = string
  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "Must be a valid Log Analytics workspace resource ID."
  }
}
```

### Optional Inputs

```hcl
variable "instance_id" {
  description = "Instance identifier for ALZ naming convention"
  type        = string
  default     = "001"
  validation {
    condition     = can(regex("^[0-9]{3}$", var.instance_id))
    error_message = "Instance ID must be exactly 3 digits."
  }
}

variable "app_service_plan_id" {
  description = "Resource ID of existing App Service Plan. If null, creates new plan."
  type        = string
  default     = null
}

variable "app_service_plan_sku" {
  description = "SKU for App Service Plan when creating new plan"
  type        = string
  default     = "B1"
  validation {
    condition     = contains(["B1", "B2", "B3", "S1", "S2", "S3", "P1", "P2", "P3", "P1v2", "P2v2", "P3v2", "P1v3", "P2v3", "P3v3"], var.app_service_plan_sku)
    error_message = "Must be a valid App Service Plan SKU."
  }
}

variable "linux_fx_version" {
  description = "Linux runtime stack for the web app"
  type        = string
  default     = "NODE|18-lts"
  validation {
    condition     = can(regex("^[A-Z]+\\|.+$", var.linux_fx_version))
    error_message = "Must be a valid Linux FX version (e.g., 'NODE|18-lts', 'PYTHON|3.9')."
  }
}

variable "site_config" {
  description = "Additional site configuration settings"
  type = object({
    always_on                 = optional(bool, true)
    use_32_bit_worker        = optional(bool, false)
    websockets_enabled       = optional(bool, false)
    app_command_line         = optional(string)
    health_check_path        = optional(string)
    client_affinity_enabled  = optional(bool, false)
  })
  default = {}
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "connection_strings" {
  description = "Connection strings for the web app"
  type = map(object({
    type  = string
    value = string
  }))
  default   = {}
  sensitive = true
  validation {
    condition = alltrue([
      for cs in var.connection_strings : contains(["SQLServer", "SQLAzure", "Custom", "NotificationHub", "ServiceBus", "EventHub", "APIHub", "DocDb", "RedisCache", "PostgreSQL", "MySQL"], cs.type)
    ])
    error_message = "Connection string type must be a valid Azure connection string type."
  }
}

variable "user_assigned_identity_ids" {
  description = "List of user-assigned managed identity resource IDs"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for id in var.user_assigned_identity_ids : can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.+$", id))
    ])
    error_message = "All identity IDs must be valid user-assigned managed identity resource IDs."
  }
}

variable "access_restrictions" {
  description = "IP access restrictions for the web app"
  type = list(object({
    name                      = string
    priority                  = number
    ip_address               = optional(string)
    virtual_network_subnet_id = optional(string)
    service_tag              = optional(string)
    description              = optional(string)
  }))
  default = []
  validation {
    condition = alltrue([
      for restriction in var.access_restrictions :
      (restriction.ip_address != null ? 1 : 0) +
      (restriction.virtual_network_subnet_id != null ? 1 : 0) +
      (restriction.service_tag != null ? 1 : 0) == 1
    ])
    error_message = "Each access restriction must specify exactly one of: ip_address, virtual_network_subnet_id, or service_tag."
  }
}

variable "deployment_slots" {
  description = "Deployment slots configuration"
  type = map(object({
    auto_swap_slot_name = optional(string)
    site_config = optional(object({
      always_on                = optional(bool)
      use_32_bit_worker       = optional(bool)
      websockets_enabled      = optional(bool)
      app_command_line        = optional(string)
      health_check_path       = optional(string)
    }))
    app_settings = optional(map(string))
    connection_strings = optional(map(object({
      type  = string
      value = string
    })))
    access_restrictions = optional(list(object({
      name                      = string
      priority                  = number
      ip_address               = optional(string)
      virtual_network_subnet_id = optional(string)
      service_tag              = optional(string)
      description              = optional(string)
    })))
  }))
  default   = {}
  sensitive = true
}

variable "tags" {
  description = "Resource tags for ALZ compliance"
  type        = map(string)
  default     = {}
}

variable "diagnostic_log_categories" {
  description = "Log categories for diagnostic settings"
  type        = list(string)
  default = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs", 
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]
}

variable "diagnostic_metric_categories" {
  description = "Metric categories for diagnostic settings"
  type        = list(string)
  default     = ["AllMetrics"]
}
```

## Output Values

```hcl
output "web_app_id" {
  description = "Resource ID of the Linux web app"
  value       = azurerm_linux_web_app.main.id
}

output "web_app_name" {
  description = "Name of the Linux web app"
  value       = azurerm_linux_web_app.main.name
}

output "web_app_default_hostname" {
  description = "Default hostname of the web app"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "web_app_custom_domain_verification_id" {
  description = "Custom domain verification ID"
  value       = azurerm_linux_web_app.main.custom_domain_verification_id
}

output "web_app_outbound_ip_addresses" {
  description = "Outbound IP addresses of the web app"
  value       = azurerm_linux_web_app.main.outbound_ip_addresses
}

output "web_app_possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses of the web app"
  value       = azurerm_linux_web_app.main.possible_outbound_ip_addresses
}

output "system_assigned_identity" {
  description = "System-assigned managed identity details"
  value = {
    principal_id = azurerm_linux_web_app.main.identity[0].principal_id
    tenant_id    = azurerm_linux_web_app.main.identity[0].tenant_id
  }
}

output "app_service_plan_id" {
  description = "Resource ID of the App Service Plan"
  value       = local.app_service_plan_id
}

output "deployment_slots" {
  description = "Deployment slot details"
  value = {
    for slot_name, slot in azurerm_linux_web_app_slot.slots : slot_name => {
      id                = slot.id
      name              = slot.name
      default_hostname  = slot.default_hostname
    }
  }
}

output "diagnostic_setting_ids" {
  description = "Resource IDs of diagnostic settings"
  value = {
    web_app = azurerm_monitor_diagnostic_setting.web_app.id
    slots   = { for name, setting in azurerm_monitor_diagnostic_setting.slots : name => setting.id }
  }
}
```

## Resource Dependencies

```text
azurerm_service_plan (conditional) → azurerm_linux_web_app
azurerm_linux_web_app → azurerm_linux_web_app_slot (for_each)
azurerm_linux_web_app → azurerm_monitor_diagnostic_setting
azurerm_linux_web_app_slot → azurerm_monitor_diagnostic_setting (for_each)
```

## Compliance Requirements

- **ALZ Naming**: All resources follow CAF naming convention
- **Security**: HTTPS-only, TLS 1.2+, managed identity enabled
- **Monitoring**: Diagnostic settings to Log Analytics with all required categories
- **Network**: Configurable access restrictions (IP, subnet, service tag)
- **Tags**: Support for required ALZ tags with validation