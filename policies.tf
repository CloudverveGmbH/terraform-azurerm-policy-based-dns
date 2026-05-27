data "azurerm_client_config" "current" {}

locals {
  policy_json_raw                = file("${path.module}/${var.policy_json_local_path}")
  alz_deploy_private_dns_generic = jsondecode(local.policy_json_raw)
  alz_policy_properties          = local.alz_deploy_private_dns_generic.properties
  alz_policy_rule_json           = replace(jsonencode(local.alz_policy_properties.policyRule), "[[", "[")
  alz_policy_version             = try(local.alz_policy_properties.metadata.version, "unknown")

  normalized_policy_definition_management_group_id = (
    var.policy_definition_at_management_group == null ? null : (
      startswith(lower(var.policy_definition_at_management_group), "/providers/microsoft.management/managementgroups/")
      ? var.policy_definition_at_management_group
      : "/providers/Microsoft.Management/managementGroups/${var.policy_definition_at_management_group}"
    )
  )

  assignment_pairs = {
    for item in flatten([
      for scope_name, scope_id in var.policy_assignment_scope_ids : [
        for mapping_key, mapping in local.effective_subresource_zone_map : {
          key         = "${scope_name}-${mapping_key}"
          scope_key   = scope_name
          scope_id    = scope_id
          mapping_key = mapping_key
          mapping     = mapping
        }
      ]
    ]) : item.key => item
  }

  rg_assignments = {
    for key, assignment in local.assignment_pairs : key => assignment
    if strcontains(lower(assignment.scope_id), "/resourcegroups/")
  }

  subscription_assignments = {
    for key, assignment in local.assignment_pairs : key => assignment
    if startswith(lower(assignment.scope_id), "/subscriptions/") && !strcontains(lower(assignment.scope_id), "/resourcegroups/")
  }

  management_group_assignments = {
    for key, assignment in local.assignment_pairs : key => assignment
    if startswith(lower(assignment.scope_id), "/providers/microsoft.management/managementgroups/")
  }

  rg_assignment_subscription_scopes = toset(distinct([
    for _, assignment in local.rg_assignments : regex("^/subscriptions/[^/]+", lower(assignment.scope_id))
  ]))

  subscription_assignment_subscription_scopes = toset(distinct([
    for _, assignment in local.subscription_assignments : lower(assignment.scope_id)
  ]))

  overlapping_subscription_scopes = toset(distinct([
    for sub_scope in local.rg_assignment_subscription_scopes : sub_scope
    if contains(local.subscription_assignment_subscription_scopes, sub_scope)
  ]))

  rg_assignment_scopes = toset(distinct([
    for _, assignment in azurerm_resource_group_policy_assignment.this : assignment.resource_group_id
  ]))

  subscription_assignment_scopes = toset(distinct([
    for _, assignment in azurerm_subscription_policy_assignment.this : assignment.subscription_id
  ]))

  management_group_assignment_scopes = toset(distinct([
    for _, assignment in azurerm_management_group_policy_assignment.this : assignment.management_group_id
  ]))

  has_assignment_scopes = (
    length(local.rg_assignment_scopes) > 0 ||
    length(local.subscription_assignment_scopes) > 0 ||
    length(local.management_group_assignment_scopes) > 0
  )
}

resource "azurerm_user_assigned_identity" "policy_assignment" {
  provider = azurerm.connectivity

  name                = var.assignment_identity_name
  location            = var.location
  resource_group_name = var.dns_resource_group_name

  lifecycle {
    precondition {
      condition     = length(local.overlapping_subscription_scopes) == 0
      error_message = "Conflicting assignment scopes: at least one subscription has both subscription-level and resource-group-level assignments. Overlaps: ${join(", ", tolist(local.overlapping_subscription_scopes))}."
    }

    precondition {
      condition     = length(local.management_group_assignments) == 0 || var.policy_definition_at_management_group != null
      error_message = "policy_assignment_scope_ids contains management group scopes but policy_definition_at_management_group is not set. The policy definition must be scoped to a management group before MG assignments can be created."
    }
  }
}

resource "azurerm_policy_definition" "deploy_private_dns_generic" {
  name                = var.policy_definition_name
  policy_type         = "Custom"
  mode                = try(local.alz_policy_properties.mode, "All")
  display_name        = var.policy_definition_display_name
  description         = try(local.alz_policy_properties.description, "Configure private DNS zone groups for private endpoints.")
  management_group_id = local.normalized_policy_definition_management_group_id

  metadata = jsonencode(merge(
    try(local.alz_policy_properties.metadata, {}),
    {
      importedFrom    = var.policy_source_repo_url
      importedVersion = local.alz_policy_version
      importedBy      = "terraform-http-jsondecode-module"
    }
  ))

  parameters  = jsonencode(local.alz_policy_properties.parameters)
  policy_rule = local.alz_policy_rule_json
}

resource "azurerm_resource_group_policy_assignment" "this" {
  for_each = local.rg_assignments

  resource_group_id = each.value.scope_id

  name                 = substr("policy-dns-rg-${md5(each.key)}", 0, 63) # policy assignment names have a max length of 64 characters
  display_name         = "Deploy Private DNS (${each.value.mapping_key})"
  description          = "Generated assignment from private_dns_policy module for scope ${each.value.scope_key}."
  policy_definition_id = azurerm_policy_definition.deploy_private_dns_generic.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.policy_assignment.id]
  }

  location = var.location

  parameters = jsonencode({
    privateDnsZoneId = {
      value = local.zone_ids[each.value.mapping.zone_name]
    }
    resourceType = {
      value = each.value.mapping.resource_type
    }
    groupId = {
      value = each.value.mapping.group_id
    }
    evaluationDelay = {
      value = var.policy_evaluation_delay
    }
    location = {
      value = var.location
    }
    effect = {
      value = var.policy_effect
    }
  })
}

resource "azurerm_subscription_policy_assignment" "this" {
  for_each = local.subscription_assignments

  subscription_id = each.value.scope_id

  name                 = substr("policy-dns-sub-${md5(each.key)}", 0, 63) # policy assignment names have a max length of 64 characters
  display_name         = "Deploy Private DNS (${each.value.mapping_key})"
  description          = "Generated assignment from private_dns_policy module for scope ${each.value.scope_key}."
  policy_definition_id = azurerm_policy_definition.deploy_private_dns_generic.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.policy_assignment.id]
  }

  location = var.location

  parameters = jsonencode({
    privateDnsZoneId = {
      value = local.zone_ids[each.value.mapping.zone_name]
    }
    resourceType = {
      value = each.value.mapping.resource_type
    }
    groupId = {
      value = each.value.mapping.group_id
    }
    evaluationDelay = {
      value = var.policy_evaluation_delay
    }
    location = {
      value = var.location
    }
    effect = {
      value = var.policy_effect
    }
  })
}

resource "azurerm_management_group_policy_assignment" "this" {
  for_each = local.management_group_assignments

  management_group_id = each.value.scope_id

  name                 = substr("pdmg${md5(each.key)}", 0, 24) # management group policy assignment names have a max length of 24 characters
  display_name         = "Deploy Private DNS (${each.value.mapping_key})"
  description          = "Generated assignment from private_dns_policy module for scope ${each.value.scope_key}."
  policy_definition_id = azurerm_policy_definition.deploy_private_dns_generic.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.policy_assignment.id]
  }

  location = var.location

  parameters = jsonencode({
    privateDnsZoneId = {
      value = local.zone_ids[each.value.mapping.zone_name]
    }
    resourceType = {
      value = each.value.mapping.resource_type
    }
    groupId = {
      value = each.value.mapping.group_id
    }
    evaluationDelay = {
      value = var.policy_evaluation_delay
    }
    location = {
      value = var.location
    }
    effect = {
      value = var.policy_effect
    }
  })
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  provider = azurerm.connectivity

  for_each = local.has_assignment_scopes ? local.zone_ids : {}

  scope                = each.value
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.policy_assignment.principal_id
}

resource "azurerm_role_assignment" "network_contributor_rg" {
  for_each = local.rg_assignment_scopes

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.policy_assignment.principal_id
}

resource "azurerm_role_assignment" "network_contributor_sub" {
  for_each = local.subscription_assignment_scopes

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.policy_assignment.principal_id
}

resource "azurerm_role_assignment" "network_contributor_mg" {
  for_each = local.management_group_assignment_scopes

  scope                = each.value
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.policy_assignment.principal_id
}
