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

# Optional variables with defaults
variable "app_service_plan_id" {
  description = "Resource ID of existing App Service Plan. If null, creates new plan."
  type        = string
  default     = null
}

variable "app_service_plan_sku" {
  description = "SKU for App Service Plan when creating new plan"
  type        = string
  default     = "B1"
}

variable "linux_fx_version" {
  description = "Linux runtime stack for the web app"
  type        = string
  default     = "NODE|18-lts"
}

variable "tags" {
  description = "Resource tags for ALZ compliance"
  type        = map(string)
  default = {
    Environment = "Development"
    Owner       = "Platform Team"
    CostCenter  = "IT-001"
  }
}