# ALZ naming convention calculations
locals {
  # Location abbreviations for ALZ naming
  location_short = {
    "East US"          = "eus"
    "East US 2"        = "eus2"
    "West US"          = "wus"
    "West US 2"        = "wus2"
    "West US 3"        = "wus3"
    "Central US"       = "cus"
    "North Central US" = "ncus"
    "South Central US" = "scus"
    "West Central US"  = "wcus"
    "Canada Central"   = "cac"
    "Canada East"      = "cae"
    "North Europe"     = "ne"
    "West Europe"      = "we"
    "UK South"         = "uks"
    "UK West"          = "ukw"
    "France Central"   = "frc"
    "Germany West Central" = "gwc"
    "Switzerland North" = "swn"
    "Norway East"      = "noe"
    "Sweden Central"   = "swc"
    "Australia East"   = "ae"
    "Australia Southeast" = "ase"
    "Australia Central" = "ac"
    "Japan East"       = "jpe"
    "Japan West"       = "jpw"
    "Korea Central"    = "krc"
    "Korea South"      = "krs"
    "Southeast Asia"   = "sea"
    "East Asia"        = "ea"
    "Central India"    = "ci"
    "South India"      = "si"
    "West India"       = "wi"
    "Brazil South"     = "brs"
    "South Africa North" = "san"
    "UAE North"        = "uan"
  }

  # ALZ compliant naming pattern: {workload}-{environment}-{region}-{instance}
  location_abbreviation = lookup(local.location_short, var.location, "unkn")
  naming_prefix         = "${var.workload_name}-${var.environment}-${local.location_abbreviation}-${var.instance_id}"
  
  # Resource names following ALZ conventions
  web_app_name         = "app-${local.naming_prefix}"
  app_service_plan_name = "plan-${local.naming_prefix}"
  diagnostic_setting_name = "diag-${local.naming_prefix}"

  # Determine App Service Plan ID (existing or to be created)
  app_service_plan_id = var.app_service_plan_id != null ? var.app_service_plan_id : azurerm_service_plan.main[0].id

  # Effective site configuration for deployment slots to inherit from
  effective_site_config = {
    always_on                         = var.site_config.always_on
    app_command_line                  = var.site_config.app_command_line
    container_registry_use_managed_identity = var.site_config.container_registry_use_managed_identity
    default_documents                 = var.site_config.default_documents
    ftps_state                       = var.site_config.ftps_state
    health_check_path                = var.site_config.health_check_path
    http2_enabled                    = var.site_config.http2_enabled
    minimum_tls_version              = var.site_config.minimum_tls_version
    remote_debugging_enabled         = var.site_config.remote_debugging_enabled
    scm_use_main_ip_restriction      = var.site_config.scm_use_main_ip_restriction
    websockets_enabled               = var.site_config.websockets_enabled
    worker_count                     = var.site_config.worker_count
  }

  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Environment = var.environment
    Workload    = var.workload_name
    ManagedBy   = "Terraform"
    Module      = "linux-webapp"
  })
}