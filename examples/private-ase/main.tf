# Private ASE Deployment Example
# This example demonstrates deploying a Linux Web App with private access restrictions
# Suitable for secure environments requiring network isolation

module "private_linux_webapp" {
  source = "../../modules/linux-webapp"

  # Core configuration
  workload_name       = var.workload_name
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name

  # App Service Plan with Private tier
  app_service_plan_sku = var.app_service_plan_sku

  # Runtime configuration
  linux_fx_version = var.linux_fx_version

  # Private network access configuration
  access_restrictions = var.access_restrictions

  # Enhanced site configuration for private deployment
  site_config = var.site_config

  # Private application settings
  app_settings = var.app_settings

  # User-assigned managed identity for secure resource access
  user_assigned_identity_ids = var.user_assigned_identity_ids

  # Diagnostic settings for security monitoring
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_log_categories  = var.diagnostic_log_categories

  # ALZ compliance tags
  tags = var.tags
}