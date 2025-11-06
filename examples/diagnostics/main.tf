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

# Enhanced diagnostics example with comprehensive logging
module "linux_web_app" {
  source = "../.."

  workload_name                = var.workload_name
  environment                  = var.environment
  location                     = var.location
  resource_group_name          = var.resource_group_name
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Production App Service Plan
  app_service_plan_sku = var.app_service_plan_sku

  # Runtime configuration
  linux_fx_version = var.linux_fx_version
  
  site_config = var.site_config

  # Application settings
  app_settings = var.app_settings

  # Enhanced diagnostic categories
  diagnostic_log_categories = var.diagnostic_log_categories

  # Example deployment slot configuration for staging
  deployment_slots = var.deployment_slots

  # ALZ compliance tags
  tags = var.tags
}