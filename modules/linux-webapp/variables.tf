# Core required variables
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

# Optional variables
variable "instance_id" {
  description = "Instance identifier for ALZ naming convention"
  type        = string
  default     = "001"
  validation {
    condition     = can(regex("^[0-9]{3}$", var.instance_id))
    error_message = "Instance ID must be exactly 3 digits."
  }
}

# App Service Plan variables
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

# Web app configuration
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

# Diagnostic settings
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

# User-assigned managed identity
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

# Access restrictions
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

# Application settings and connection strings
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

# Deployment slots configuration
variable "deployment_slots" {
  description = "Configuration for deployment slots"
  type = map(object({
    site_config = optional(object({
      always_on                         = optional(bool)
      app_command_line                  = optional(string)
      auto_heal_enabled                 = optional(bool)
      container_registry_use_managed_identity = optional(bool)
      default_documents                 = optional(list(string))
      ftps_state                       = optional(string)
      health_check_path                = optional(string)
      health_check_grace_period        = optional(number)
      http2_enabled                    = optional(bool)
      minimum_tls_version              = optional(string)
      remote_debugging_enabled         = optional(bool)
      scm_use_main_ip_restriction      = optional(bool)
      use_32_bit_worker_process        = optional(bool)
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
  default = {}
}

# Connection strings for main web app
variable "connection_strings" {
  description = "Connection strings for the web app"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
  validation {
    condition = alltrue([
      for cs in var.connection_strings :
      contains(["APIHub", "Custom", "DocDb", "EventHub", "MySQL", "NotificationHub", "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer"], cs.type)
    ])
    error_message = "Connection string type must be one of: APIHub, Custom, DocDb, EventHub, MySQL, NotificationHub, PostgreSQL, RedisCache, ServiceBus, SQLAzure, SQLServer."
  }
}

variable "tags" {
  description = "Resource tags for ALZ compliance"
  type        = map(string)
  default     = {}
}