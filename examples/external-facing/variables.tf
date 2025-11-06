# External-Facing Web App Example Variables
# This example demonstrates an external-facing deployment with public access

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
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

# App Service Plan Configuration
variable "app_service_plan_id" {
  description = "Resource ID of existing App Service Plan. If null, creates new plan."
  type        = string
  default     = null
}

variable "app_service_plan_sku" {
  description = "App Service Plan SKU for external deployment"
  type        = string
  default     = "P1v3" # Premium tier for production workloads
}

# Runtime Configuration
variable "linux_fx_version" {
  description = "Linux runtime stack"
  type        = string
  default     = "NODE|18-lts"
}

# Site Configuration for External Deployment
variable "site_config" {
  description = "Site configuration for external deployment"
  type = object({
    always_on                 = optional(bool, true)
    use_32_bit_worker        = optional(bool, false)
    websockets_enabled       = optional(bool, false)
    app_command_line         = optional(string)
    health_check_path        = optional(string, "/health")
    client_affinity_enabled  = optional(bool, false)
  })
  default = {
    always_on              = true
    use_32_bit_worker      = false
    websockets_enabled     = false
    health_check_path      = "/health"
    client_affinity_enabled = false
  }
}

# External Application Settings
variable "app_settings" {
  description = "Application settings for external deployment"
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
  description = "List of user-assigned managed identity resource IDs for secure resource access"
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
    Environment        = "Production"
    Owner             = "Platform Team"
    CostCenter        = "IT-001"
    Compliance        = "ALZ"
    DataClassification = "Public"
    NetworkType       = "External"
  }
}
