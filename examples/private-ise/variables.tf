# Private ASE Example Variables
# This example demonstrates private access restrictions and enhanced security

# Core Required Variables
variable "workload_name" {
  description = "The workload name for ALZ naming convention"
  type        = string
  default     = "webapp"
}

variable "environment" {
  description = "The environment (e.g., dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "The Azure region for resources"
  type        = string
  default     = "East US 2"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# App Service Plan Configuration
variable "app_service_plan_sku" {
  description = "App Service Plan SKU for private deployment"
  type        = string
  default     = "P2v3" # Premium tier for private ASE
}

# Runtime Configuration
variable "linux_fx_version" {
  description = "Linux runtime stack"
  type        = string
  default     = "NODE|18-lts"
}

# Private Access Configuration
variable "access_restrictions" {
  description = "Network access restrictions for private deployment"
  type = list(object({
    name                      = string
    priority                  = number
    action                    = string
    ip_address               = optional(string)
    service_tag              = optional(string)
    virtual_network_subnet_id = optional(string)
    description              = optional(string)
  }))
  default = [
    {
      name        = "AllowVNetAccess"
      priority    = 100
      action      = "Allow"
      service_tag = "VirtualNetwork"
      description = "Allow access from virtual networks only"
    },
    {
      name        = "AllowAzureServices"
      priority    = 200
      action      = "Allow"
      service_tag = "AzureCloud"
      description = "Allow Azure services"
    },
    {
      name        = "DenyInternet"
      priority    = 300
      action      = "Deny"
      ip_address  = "0.0.0.0/0"
      description = "Deny all internet access"
    }
  ]
}

# Enhanced Site Configuration for Private Deployment
variable "site_config" {
  description = "Site configuration for private ASE deployment"
  type = object({
    always_on                         = optional(bool, true)
    app_command_line                  = optional(string)
    auto_heal_enabled                 = optional(bool, true)
    container_registry_use_managed_identity = optional(bool, true)
    default_documents                 = optional(list(string))
    ftps_state                       = optional(string, "Disabled")
    health_check_path                = optional(string, "/health")
    health_check_grace_period        = optional(number, 600)
    http2_enabled                    = optional(bool, true)
    minimum_tls_version              = optional(string, "1.2")
    remote_debugging_enabled         = optional(bool, false)
    scm_use_main_ip_restriction      = optional(bool, true)
    use_32_bit_worker_process        = optional(bool, false)
    websockets_enabled               = optional(bool, false)
    worker_count                     = optional(number, 2)
  })
  default = {
    always_on                         = true
    auto_heal_enabled                 = true
    container_registry_use_managed_identity = true
    ftps_state                       = "Disabled"
    health_check_path                = "/health"
    health_check_grace_period        = 600
    http2_enabled                    = true
    minimum_tls_version              = "1.2"
    remote_debugging_enabled         = false
    scm_use_main_ip_restriction      = true
    use_32_bit_worker_process        = false
    websockets_enabled               = false
    worker_count                     = 2
  }
}

# Private Application Settings
variable "app_settings" {
  description = "Application settings for private deployment"
  type        = map(string)
  default = {
    "WEBSITE_NODE_DEFAULT_VERSION"     = "18.17.0"
    "NODE_ENV"                         = "production"
    "WEBSITE_HTTPLOGGING_RETENTION_DAYS" = "30"
    "WEBSITE_HEALTHCHECK_MAXPINGFAILURES" = "3"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"   = "false"
    "ENABLE_ORYX_BUILD"               = "false"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = "true"
    "WEBSITE_RUN_FROM_PACKAGE"        = "1"
  }
}

# Managed Identity Configuration
variable "user_assigned_identity_ids" {
  description = "List of user-assigned managed identity resource IDs"
  type        = list(string)
  default     = []
}

# Diagnostic Settings
variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for diagnostic settings"
  type        = string
}

variable "diagnostic_log_categories" {
  description = "Diagnostic log categories to enable"
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

# ALZ Compliance Tags
variable "tags" {
  description = "Resource tags for ALZ compliance"
  type        = map(string)
  default = {
    Environment     = "Production"
    Owner          = "Security Team"
    CostCenter     = "SEC-001"
    Compliance     = "ALZ"
    DataClassification = "Confidential"
    BackupRequired = "true"
    SecurityLevel  = "High"
  }
}