#
# Diagnostic outputs — NOT part of the stable module API.
#
# These expose internal computed state that is not needed by module callers
# but is required by `terraform test` assertions, since the test framework
# can only access output.* values (not local.* or resource.*).
#
# Also useful during development and debugging.
#

output "effective_subresource_zone_map" {
  description = "[diagnostic] Final resolved subresource mapping after category/service selection and overrides."
  value       = local.effective_subresource_zone_map
}

output "category_service_keys" {
  description = "[diagnostic] Resolved category-to-service-key lookup built from the catalog."
  value       = local.category_service_keys
}

output "rg_assignment_scopes" {
  description = "[diagnostic] Deduplicated set of resource group IDs that received policy assignments."
  value       = local.rg_assignment_scopes
}

output "subscription_assignment_scopes" {
  description = "[diagnostic] Deduplicated set of subscription IDs that received policy assignments."
  value       = local.subscription_assignment_scopes
}

output "management_group_assignment_scopes" {
  description = "[diagnostic] Deduplicated set of management group IDs that received policy assignments."
  value       = local.management_group_assignment_scopes
}
