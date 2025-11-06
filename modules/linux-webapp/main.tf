# Data sources for existing resources
data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Local computations
locals {
  # Determine App Service Plan ID (existing or to be created)
  app_service_plan_id = var.app_service_plan_id != null ? var.app_service_plan_id : azurerm_service_plan.main[0].id
}

# Conditional App Service Plan creation
resource "azurerm_service_plan" "main" {
  count = var.app_service_plan_id == null ? 1 : 0

  name                = local.app_service_plan_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku

  tags = local.common_tags
}

# Linux Web App with ALZ-compliant defaults
resource "azurerm_linux_web_app" "main" {
  name                = local.web_app_name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = var.resource_group_name
  service_plan_id     = local.app_service_plan_id

  # ALZ Security Requirements
  https_only                    = true
  client_affinity_enabled       = var.site_config.client_affinity_enabled
  public_network_access_enabled = true # Will be configurable in US2

  # Site configuration with secure defaults
  site_config {
    minimum_tls_version    = "1.2"
    scm_minimum_tls_version = "1.2"
    ftps_state            = "FtpsOnly"
    linux_fx_version      = var.linux_fx_version
    
    always_on                 = var.site_config.always_on
    use_32_bit_worker        = var.site_config.use_32_bit_worker
    websockets_enabled       = var.site_config.websockets_enabled
    app_command_line         = var.site_config.app_command_line
    health_check_path        = var.site_config.health_check_path

    # Access restrictions
    dynamic "ip_restriction" {
      for_each = var.access_restrictions
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = "Allow"
        ip_address               = ip_restriction.value.ip_address
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        service_tag              = ip_restriction.value.service_tag
        description              = ip_restriction.value.description
      }
    }
  }

  # Managed identity configuration
  identity {
    type         = length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = length(var.user_assigned_identity_ids) > 0 ? var.user_assigned_identity_ids : null
  }

  # Application settings
  app_settings = var.app_settings

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  tags = local.common_tags
}

# Diagnostic Settings for ALZ compliance
resource "azurerm_monitor_diagnostic_setting" "web_app" {
  name                       = local.diagnostic_setting_name
  target_resource_id         = azurerm_linux_web_app.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Enable all required log categories
  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  # Enable metrics
  dynamic "metric" {
    for_each = var.diagnostic_metric_categories
    content {
      category = metric.value
    }
  }
}

# Deployment slots for zero-downtime deployments
resource "azurerm_linux_web_app_slot" "slots" {
  for_each = var.deployment_slots

  name           = each.key
  app_service_id = azurerm_linux_web_app.main.id

  # Site configuration inherits from main app with overrides
  site_config {
    always_on                         = coalesce(each.value.site_config.always_on, local.effective_site_config.always_on)
    app_command_line                  = coalesce(each.value.site_config.app_command_line, local.effective_site_config.app_command_line)
    container_registry_use_managed_identity = coalesce(each.value.site_config.container_registry_use_managed_identity, local.effective_site_config.container_registry_use_managed_identity)
    default_documents                 = coalesce(each.value.site_config.default_documents, local.effective_site_config.default_documents)
    ftps_state                       = coalesce(each.value.site_config.ftps_state, local.effective_site_config.ftps_state)
    health_check_path                = coalesce(each.value.site_config.health_check_path, local.effective_site_config.health_check_path)
    http2_enabled                    = coalesce(each.value.site_config.http2_enabled, local.effective_site_config.http2_enabled)
    minimum_tls_version              = coalesce(each.value.site_config.minimum_tls_version, local.effective_site_config.minimum_tls_version)
    remote_debugging_enabled         = coalesce(each.value.site_config.remote_debugging_enabled, local.effective_site_config.remote_debugging_enabled)
    scm_use_main_ip_restriction      = coalesce(each.value.site_config.scm_use_main_ip_restriction, local.effective_site_config.scm_use_main_ip_restriction)
    websockets_enabled               = coalesce(each.value.site_config.websockets_enabled, local.effective_site_config.websockets_enabled)
    worker_count                     = coalesce(each.value.site_config.worker_count, local.effective_site_config.worker_count)

    # Inherit access restrictions from main app for security consistency
    dynamic "ip_restriction" {
      for_each = var.access_restrictions
      content {
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                   = "Allow"
        ip_address               = ip_restriction.value.ip_address
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        service_tag              = ip_restriction.value.service_tag
        description              = ip_restriction.value.description
      }
    }
  }

  # Inherit managed identity from main app
  identity {
    type         = length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = length(var.user_assigned_identity_ids) > 0 ? var.user_assigned_identity_ids : null
  }

  # Merge slot-specific app settings with defaults
  app_settings = merge(var.app_settings, each.value.app_settings)

  # Slot-specific connection strings
  dynamic "connection_string" {
    for_each = each.value.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  tags = local.common_tags
}

# Diagnostic Settings for deployment slots
resource "azurerm_monitor_diagnostic_setting" "slot_diagnostics" {
  for_each = var.deployment_slots

  name                       = "${local.diagnostic_setting_name}-${each.key}"
  target_resource_id         = azurerm_linux_web_app_slot.slots[each.key].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Enable all required log categories
  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  # Enable metrics
  dynamic "metric" {
    for_each = var.diagnostic_metric_categories
    content {
      category = metric.value
    }
  }
}