mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

mock_provider "azurerm" {
  alias = "connectivity"

  mock_data "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/mock.zone"
    }
  }
}

mock_provider "http" {
  mock_data "http" {
    defaults = {
      response_body = "{\"properties\":{\"metadata\":{\"version\":\"test\"},\"parameters\":{},\"policyRule\":{\"if\":{\"field\":\"type\",\"equals\":\"Microsoft.Network/privateEndpoints\"},\"then\":{\"effect\":\"DeployIfNotExists\"}}}}"
    }
  }
}

run "rg_scopes_deduplicated_with_multiple_services" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids = {
      rg1 = "/subscriptions/35fd1a36-57d7-499b-8234-96084acac0aa/resourceGroups/rg-clv-connectivity-weu"
      rg2 = "/subscriptions/35fd1a36-57d7-499b-8234-96084acac0aa/resourceGroups/rg-another-workload"
    }
    enabled_categories = {
      Storage = true
    }
    enabled_services  = null
    service_overrides = {}
  }

  assert {
    condition     = length(output.rg_assignment_scopes) == 2
    error_message = "Expected exactly 2 deduplicated RG scopes (rg1 and rg2), but got ${length(output.rg_assignment_scopes)}"
  }

  assert {
    condition     = contains(output.rg_assignment_scopes, "/subscriptions/35fd1a36-57d7-499b-8234-96084acac0aa/resourceGroups/rg-clv-connectivity-weu")
    error_message = "Expected rg1 to be in rg_assignment_scopes"
  }

  assert {
    condition     = contains(output.rg_assignment_scopes, "/subscriptions/35fd1a36-57d7-499b-8234-96084acac0aa/resourceGroups/rg-another-workload")
    error_message = "Expected rg2 to be in rg_assignment_scopes"
  }
}

run "mg_definition_without_mg_assignments" {
  command = plan

  variables {
    location                              = "germanywestcentral"
    region_code                           = "gwc"
    dns_resource_group_name               = "rg-dns"
    policy_definition_name                = "test-def"
    policy_definition_display_name        = "test-def"
    policy_assignment_scope_ids           = {}
    policy_definition_at_management_group = "mg-platform-test"
    enabled_categories                    = null
    enabled_services = {
      blob = false
    }
    service_overrides = {}
  }

  assert {
    condition     = length(output.management_group_assignment_scopes) == 0
    error_message = "Expected no MG assignments when no MG assignment scopes are provided."
  }

  assert {
    condition     = length(output.subscription_assignment_scopes) == 0
    error_message = "Expected no subscription assignments in this scenario."
  }
}

run "mg_assignments_from_generic_scope_list" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids = {
      mg_platform = "/providers/Microsoft.Management/managementGroups/mg-platform-test"
    }
    policy_definition_at_management_group = "mg-platform-test"
    enabled_categories                    = null
    enabled_services = {
      blob = false
    }
    service_overrides = {}
  }

  assert {
    condition     = length(output.management_group_assignment_scopes) == 1
    error_message = "Expected MG assignments from generic MG assignment scope list."
  }

  assert {
    condition     = contains(output.management_group_assignment_scopes, "/providers/Microsoft.Management/managementGroups/mg-platform-test")
    error_message = "Expected mg-platform-test to be present in management_group_assignment_scopes."
  }
}

run "mg_defined_without_assignment_with_sub_and_rg" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids = {
      rg_sub_b = "/subscriptions/11111111-2222-3333-4444-555555555555/resourceGroups/rg-app-sub-b"
      sub_main = "/subscriptions/00000000-0000-0000-0000-000000000000"
    }
    policy_definition_at_management_group = "mg-platform-test"
    enabled_categories                    = null
    enabled_services = {
      blob = false
    }
    service_overrides = {}
  }

  assert {
    condition     = length(output.management_group_assignment_scopes) == 0
    error_message = "Expected no MG assignments when no MG assignment scopes are provided."
  }

  assert {
    condition     = length(output.subscription_assignment_scopes) == 1
    error_message = "Expected one subscription assignment scope."
  }

  assert {
    condition     = contains(output.subscription_assignment_scopes, "/subscriptions/00000000-0000-0000-0000-000000000000")
    error_message = "Expected explicit subscription scope from policy_assignment_scope_ids."
  }

  assert {
    condition     = length(output.rg_assignment_scopes) == 1
    error_message = "Expected one RG assignment scope for subscription B RG input."
  }

  assert {
    condition     = contains(output.rg_assignment_scopes, "/subscriptions/11111111-2222-3333-4444-555555555555/resourceGroups/rg-app-sub-b")
    error_message = "Expected RG scope in subscription B to be included."
  }
}

run "reject_mg_assignment_without_definition_at_mg" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids = {
      mg_platform = "/providers/Microsoft.Management/managementGroups/mg-platform-test"
    }
    # policy_definition_at_management_group intentionally omitted
    enabled_categories = null
    enabled_services = {
      blob = false
    }
    service_overrides = {}
  }

  expect_failures = [
    azurerm_user_assigned_identity.policy_assignment
  ]
}

run "reject_overlapping_subscription_and_rg_assignment_scopes" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids = {
      sub_main = "/subscriptions/00000000-0000-0000-0000-000000000000"
      rg_main  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-overlap"
    }
    enabled_categories = null
    enabled_services = {
      blob = false
    }
    service_overrides = {}
  }

  expect_failures = [
    azurerm_user_assigned_identity.policy_assignment
  ]
}
