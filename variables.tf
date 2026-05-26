variable "location" {
  type        = string
  description = "Azure location used for policy assignments with managed identity."
}

variable "region_code" {
  type        = string
  description = "Optional region code used for services that require a geo/region code in the DNS zone name (for example Azure Backup)."
  default     = "gwc"
}

variable "dns_resource_group_name" {
  type        = string
  description = "Resource group name in connectivity subscription hosting private DNS zones."
}

variable "policy_definition_name" {
  type        = string
  description = "Name of the custom policy definition created from ALZ JSON."
  default     = "clv-deploy-private-dns-generic"
}

variable "policy_definition_display_name" {
  type        = string
  description = "Display name for the custom policy definition."
  default     = "CLV - Deploy Private DNS Generic"
}

variable "policy_source_raw_url" {
  type        = string
  description = "Raw GitHub URL for Deploy-Private-DNS-Generic policy JSON."
  default     = "https://raw.githubusercontent.com/Azure/Enterprise-Scale/2026-04-29/src/resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic.json"
}

variable "policy_source_repo_url" {
  type        = string
  description = "Repository URL used in metadata to track source import."
  default     = "https://github.com/Azure/Enterprise-Scale/tree/2026-04-29/src/resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic.json"
}

variable "policy_json_local_path" {
  type        = string
  description = "Path (relative to module root) of the vendored Deploy-Private-DNS-Generic policy JSON used as authoritative source."
  default     = "policy_definitions/Deploy-Private-DNS-Generic.2026-04-29.json"
}

variable "expected_policy_json_sha256" {
  type        = string
  description = "Expected SHA256 of the vendored policy JSON. Apply fails if file content differs."
  default     = "a2e3805c1129b5d540f38fbfe9f3c0608926c64526023a22fdaac7b81b22287a"
}

variable "enable_latest_version_check" {
  type        = bool
  description = "When true, fetches Deploy-Private-DNS-Generic from Enterprise-Scale main and compares metadata.version against imported_policy_version."
  default     = true
}

variable "policy_effect" {
  type        = string
  description = "Policy effect value."
  default     = "DeployIfNotExists"

  validation {
    condition     = contains(["DeployIfNotExists", "Disabled"], var.policy_effect)
    error_message = "policy_effect must be DeployIfNotExists or Disabled."
  }
}

variable "policy_evaluation_delay" {
  type        = string
  description = "Evaluation delay used by DINE policy assignments."
  default     = "AfterProvisioningSuccess"
}

variable "enabled_categories" {
  description = "Category selectors with create_zone flag. Example: { Storage = true, Web = false }."
  type        = map(bool)
  default     = null
  nullable    = true
}

variable "enabled_services" {
  description = "Explicit service selectors with create_zone flag. Overrides enabled_categories for matching service keys. Example: { staticwebapp = true }."
  type        = map(bool)
  default     = null
  nullable    = true
}

variable "service_overrides" {
  description = "Optional per-service-key override for group, resource type, zone name and pre-existing zone ID. For DNS zones in a different subscription, existing_zone_id is required; data source lookup is limited to dns_resource_group_name within the connectivity subscription."
  type = map(object({
    group_id         = optional(string)
    resource_type    = optional(string)
    zone_name        = optional(string)
    existing_zone_id = optional(string)
  }))
  default = {}
}

variable "policy_assignment_scope_ids" {
  description = "Generic assignment scopes keyed by friendly name. Values are resource group, subscription, or management group IDs; scope type is detected from the ID format."
  type        = map(string)
  default     = {}
}

variable "policy_definition_at_management_group" {
  description = "Optional management group ID where the policy definition should be created. Accepts either full MG resource ID or MG short name."
  type        = string
  default     = null
  nullable    = true
}

variable "assignment_identity_name" {
  description = "Name of the single user-assigned managed identity used by all policy assignments."
  type        = string
  default     = "id-clv-private-dns-policy"
}

variable "vnet_links" {
  description = "VNets to link to all DNS zones created by this module (not applied to existing/forced zones). Key is a friendly name used in the link resource name, value is the full VNet resource ID."
  type        = map(string)
  default     = {}
}
