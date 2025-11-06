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

# Basic ALZ-compliant Linux Web App deployment
module "linux_web_app" {
  source = "../.."

  workload_name                = var.workload_name
  environment                  = var.environment
  location                     = var.location
  resource_group_name          = var.resource_group_name
  log_analytics_workspace_id   = var.log_analytics_workspace_id

  # Optional: Use existing App Service Plan or create new one
  app_service_plan_id = var.app_service_plan_id
  app_service_plan_sku = var.app_service_plan_sku

  # Runtime configuration
  linux_fx_version = var.linux_fx_version

  # ALZ compliance tags
  tags = var.tags
}