# Core web app outputs
output "web_app_id" {
  description = "Resource ID of the Linux web app"
  value       = azurerm_linux_web_app.main.id
}

output "web_app_name" {
  description = "Name of the Linux web app"
  value       = azurerm_linux_web_app.main.name
}

output "web_app_default_hostname" {
  description = "Default hostname of the web app"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "web_app_custom_domain_verification_id" {
  description = "Custom domain verification ID"
  value       = azurerm_linux_web_app.main.custom_domain_verification_id
}

output "web_app_outbound_ip_addresses" {
  description = "Outbound IP addresses of the web app"
  value       = azurerm_linux_web_app.main.outbound_ip_addresses
}

output "web_app_possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses of the web app"
  value       = azurerm_linux_web_app.main.possible_outbound_ip_addresses
}

# Managed identity outputs
output "system_assigned_identity" {
  description = "System-assigned managed identity details"
  value = {
    principal_id = azurerm_linux_web_app.main.identity[0].principal_id
    tenant_id    = azurerm_linux_web_app.main.identity[0].tenant_id
  }
}

output "user_assigned_identities" {
  description = "User-assigned managed identity details"
  value = length(var.user_assigned_identity_ids) > 0 ? {
    for id in var.user_assigned_identity_ids : 
    split("/", id)[length(split("/", id)) - 1] => {
      id           = id
      principal_id = azurerm_linux_web_app.main.identity[0].principal_id
      client_id    = azurerm_linux_web_app.main.identity[0].tenant_id
    }
  } : {}
}

# App Service Plan outputs
output "app_service_plan_id" {
  description = "Resource ID of the App Service Plan"
  value       = local.app_service_plan_id
}

# Diagnostic settings outputs
output "diagnostic_setting_ids" {
  description = "Resource IDs of diagnostic settings"
  value = merge(
    {
      web_app = azurerm_monitor_diagnostic_setting.web_app.id
    },
    {
      for slot_name, slot in azurerm_linux_web_app_slot.slots :
      "slot_${slot_name}" => azurerm_monitor_diagnostic_setting.slot_diagnostics[slot_name].id
    }
  )
}

# Deployment slot outputs
output "deployment_slots" {
  description = "Deployment slot details"
  value = {
    for slot_name, slot in azurerm_linux_web_app_slot.slots :
    slot_name => {
      id                   = slot.id
      name                 = slot.name
      default_hostname     = slot.default_hostname
      system_assigned_identity = {
        principal_id = slot.identity[0].principal_id
        tenant_id    = slot.identity[0].tenant_id
      }
    }
  }
}