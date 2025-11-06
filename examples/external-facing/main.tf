terraform {
  required_version = ">= 1.7.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# External-Facing Web App deployment
# This example demonstrates deploying a Linux Web App with:
# - Public network access ENABLED
# - No private endpoint (public internet access)
# - Standard external-facing configuration

module "external_linux_webapp" {
  source = "../.."

  # Core configuration
  workload_name       = var.workload_name
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name

  # App Service Plan configuration
  app_service_plan_id  = var.app_service_plan_id
  app_service_plan_sku = var.app_service_plan_sku

  # Runtime configuration
  linux_fx_version = var.linux_fx_version

  # Network security - ENABLE public access
  public_network_access_enabled = true

  # No private endpoint for external deployment
  private_endpoint = {
    enabled = false
  }

  # Site configuration for external deployment
  site_config = var.site_config

  # Application settings
  app_settings = var.app_settings

  # User-assigned managed identity for secure resource access
  user_assigned_identity_ids = var.user_assigned_identity_ids

  # Diagnostic settings for monitoring
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_log_categories  = var.diagnostic_log_categories

  # ALZ compliance tags
  tags = var.tags
}
