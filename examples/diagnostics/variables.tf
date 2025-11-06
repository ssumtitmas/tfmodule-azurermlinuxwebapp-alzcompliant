# Required variables
variable "workload_name" {
  description = "Name of the workload/application for ALZ naming convention"
  type        = string
}

variable "environment" {
  description = "Environment name for ALZ naming convention"
  type        = string
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
}

# Optional variables with enhanced defaults for diagnostics
variable "app_service_plan_sku" {
  description = "SKU for App Service Plan when creating new plan"
  type        = string
  default     = "P1v3"
}

variable "linux_fx_version" {
  description = "Linux runtime stack for the web app"
  type        = string
  default     = "NODE|18-lts"
}

variable "site_config" {
  description = "Site configuration settings"
  type = object({
    always_on                 = optional(bool, true)
    use_32_bit_worker        = optional(bool, false)
    websockets_enabled       = optional(bool, false)
    app_command_line         = optional(string)
    health_check_path        = optional(string, "/health")
    client_affinity_enabled  = optional(bool, false)
  })
  default = {
    always_on         = true
    health_check_path = "/health"
  }
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "18.17.0"
    "NODE_ENV"                     = "production"
  }
  sensitive = true
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

variable "tags" {
  description = "Resource tags for ALZ compliance"
  type        = map(string)
  default = {
    Environment     = "Production"
    Owner          = "Application Team"
    CostCenter     = "LOB-001"
    Compliance     = "ALZ"
    BackupRequired = "true"
  }
}

# Deployment slots configuration
variable "deployment_slots" {
  description = "Configuration for deployment slots"
  type = map(object({
    site_config = optional(object({
      always_on                         = optional(bool)
      app_command_line                  = optional(string)
      container_registry_use_managed_identity = optional(bool)
      default_documents                 = optional(list(string))
      ftps_state                       = optional(string)
      health_check_path                = optional(string)
      http2_enabled                    = optional(bool)
      minimum_tls_version              = optional(string)
      remote_debugging_enabled         = optional(bool)
      scm_use_main_ip_restriction      = optional(bool)
      websockets_enabled               = optional(bool)
      worker_count                     = optional(number)
    }))
    app_settings = optional(map(string), {})
    connection_strings = optional(list(object({
      name  = string
      type  = string
      value = string
    })), [])
  }))
  default = {
    staging = {
      site_config = {
        always_on           = true
        health_check_path   = "/health"
        minimum_tls_version = "1.2"
      }
      app_settings = {
        "ASPNETCORE_ENVIRONMENT" = "Staging"
        "SLOT_NAME"             = "staging"
      }
    }
  }
}