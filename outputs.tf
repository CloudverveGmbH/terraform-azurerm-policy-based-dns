#
# Module interface outputs — intended for callers of this module.
#

output "policy_definition_id" {
  description = "ID of the imported custom policy definition used for private DNS remediation."
  value       = azurerm_policy_definition.deploy_private_dns_generic.id
}

output "imported_policy_version" {
  description = "Version imported from ALZ Deploy-Private-DNS-Generic metadata."
  value       = local.alz_policy_version
}

output "policy_json_sha256" {
  description = "SHA256 of the vendored Deploy-Private-DNS-Generic policy JSON used by this module."
  value       = local.policy_json_sha256
}

output "latest_main_policy_version" {
  description = "Version from properties.metadata.version in the Deploy-Private-DNS-Generic policy on Enterprise-Scale main."
  value       = local.latest_main_policy_version
}

output "has_later_version" {
  description = "True when latest_main_policy_version is newer than imported_policy_version (numeric segment comparison)."
  value       = local.has_later_version
}

output "zone_ids" {
  description = "Resolved private DNS zone IDs keyed by zone_name. Useful for creating additional VNet links or referencing zones outside this module."
  value       = local.zone_ids
}

output "assignment_principal_ids" {
  description = "Principal ID of the single user-assigned managed identity used by all policy assignments. Useful for granting additional RBAC roles externally."
  value       = [azurerm_user_assigned_identity.policy_assignment.principal_id]
}

output "vnet_link_ids" {
  description = "Map of VNet link resource names to their IDs. Keyed by '{zone_name}-{vnet_key}' (dots replaced with dashes)."
  value       = { for k, link in azurerm_private_dns_zone_virtual_network_link.this : k => link.id }
}
