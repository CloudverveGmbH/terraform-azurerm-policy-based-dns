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

run "storage_category_creates_zones" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories = {
      Storage = true
    }
    enabled_services  = null
    service_overrides = {}
  }

  assert {
    condition     = output.effective_subresource_zone_map["blob"].create_zone == true
    error_message = "Expected Storage category to enable blob with create_zone=true."
  }

  assert {
    condition     = output.effective_subresource_zone_map["file"].create_zone == true
    error_message = "Expected Storage category to enable file with create_zone=true."
  }

  assert {
    condition     = !contains(keys(output.effective_subresource_zone_map), "webapp")
    error_message = "Expected non-Storage services to stay disabled for Storage-only input."
  }
}

run "hybrid_category_with_blob_as_existing_zone" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories = {
      Hybrid = true
    }
    enabled_services = {
      blob = false
    }
    service_overrides = {}
  }

  assert {
    condition     = output.effective_subresource_zone_map["arc_his"].create_zone == true
    error_message = "Expected arc_his (Hybrid) to have create_zone=true."
  }

  assert {
    condition     = output.effective_subresource_zone_map["blob"].create_zone == false
    error_message = "Expected blob to be present with create_zone=false."
  }
}

run "web_category_with_service_override" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories = {
      Web = false
    }
    enabled_services = {
      staticwebapp = true
    }
    service_overrides = {}
  }

  assert {
    condition     = output.effective_subresource_zone_map["webapp"].create_zone == false
    error_message = "Expected Web category to set webapp create_zone=false."
  }

  assert {
    condition     = output.effective_subresource_zone_map["staticwebapp"].create_zone == true
    error_message = "Expected explicit staticwebapp=true to override Web category create_zone=false."
  }
}

run "shared_zone_deduplicated" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    # blob and azuremonitor_blob both reference privatelink.blob.core.windows.net
    enabled_services = {
      blob              = false
      azuremonitor_blob = false
    }
    service_overrides = {}
  }

  assert {
    condition     = length(output.effective_subresource_zone_map) == 2
    error_message = "Expected 2 active services (blob + azuremonitor_blob)."
  }

  assert {
    condition     = length(output.zone_ids) == 1
    error_message = "Expected zone_ids to deduplicate: blob and azuremonitor_blob share the same zone, so only 1 unique zone entry expected."
  }
}

run "empty_selection_results_in_empty_map" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    enabled_services               = null
    service_overrides              = {}
  }

  assert {
    condition     = length(output.effective_subresource_zone_map) == 0
    error_message = "Expected empty computed mapping when no categories/services are selected."
  }
}

run "regional_aks_key_override" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    # Enable all Compute services (reference zones only, no create)
    enabled_categories = {
      Compute = false
    }
    # Override just the weu regional AKS key to create its zone
    enabled_services = {
      aks_weu = true
    }
    service_overrides = {}
  }

  assert {
    condition     = output.effective_subresource_zone_map["aks_weu"].create_zone == true
    error_message = "Expected aks_weu explicit override to set create_zone=true."
  }

  assert {
    condition     = output.effective_subresource_zone_map["aks"].create_zone == false
    error_message = "Expected aks (base, from Compute category) to remain create_zone=false."
  }

  assert {
    condition     = output.effective_subresource_zone_map["aks_weu"].zone_name == "privatelink.westeurope.azmk8s.io"
    error_message = "Expected aks_weu to have the hardcoded westeurope zone name."
  }

  assert {
    condition     = output.effective_subresource_zone_map["aks_gwc"].create_zone == false
    error_message = "Expected aks_gwc (from Compute category) to remain create_zone=false."
  }
}

run "existing_zone_id_override_is_used" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    enabled_services = {
      aks_weu = true
    }
    service_overrides = {
      aks_weu = {
        existing_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
      }
    }
  }

  assert {
    condition     = output.zone_ids["privatelink.westeurope.azmk8s.io"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
    error_message = "Expected zone_ids for privatelink.westeurope.azmk8s.io to use existing_zone_id from service_overrides."
  }
}

run "existing_zone_id_auto_activates_catalog_key" {
  # A catalog key with only existing_zone_id in service_overrides (no enabled_services entry)
  # must be auto-activated with create_zone=false and use the provided ID directly.
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    enabled_services               = null
    service_overrides = {
      aks = {
        existing_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aks/providers/Microsoft.Network/privateDnsZones/privatelink.germanywestcentral.azmk8s.io"
      }
    }
  }

  assert {
    condition     = contains(keys(output.effective_subresource_zone_map), "aks")
    error_message = "Expected aks to be auto-activated when existing_zone_id is set in service_overrides."
  }

  assert {
    condition     = output.effective_subresource_zone_map["aks"].create_zone == false
    error_message = "Expected aks auto-activated via existing_zone_id to have create_zone=false."
  }

  assert {
    condition     = output.zone_ids["privatelink.germanywestcentral.azmk8s.io"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aks/providers/Microsoft.Network/privateDnsZones/privatelink.germanywestcentral.azmk8s.io"
    error_message = "Expected zone_ids to use the provided existing_zone_id directly."
  }
}

run "existing_zone_id_auto_activates_multiple_catalog_keys" {
  # Multiple catalog keys with only existing_zone_id — all must be auto-activated,
  # no enabled_services entries needed.
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    enabled_services               = null
    service_overrides = {
      aks = {
        existing_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aks/providers/Microsoft.Network/privateDnsZones/privatelink.germanywestcentral.azmk8s.io"
      }
      vault = {
        existing_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
      }
    }
  }

  assert {
    condition     = contains(keys(output.effective_subresource_zone_map), "aks")
    error_message = "Expected aks to be auto-activated."
  }

  assert {
    condition     = contains(keys(output.effective_subresource_zone_map), "vault")
    error_message = "Expected vault to be auto-activated."
  }

  assert {
    condition     = length(output.effective_subresource_zone_map) == 2
    error_message = "Expected exactly 2 active services (aks + vault), nothing else."
  }
}

run "existing_zone_id_combined_with_category" {
  # Category activates several services; one of them also has existing_zone_id.
  # The existing_zone_id must win for that key's zone resolution.
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories = {
      Security = true
    }
    enabled_services = null
    service_overrides = {
      vault = {
        existing_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
      }
    }
  }

  assert {
    condition     = contains(keys(output.effective_subresource_zone_map), "vault")
    error_message = "Expected vault to be active (via Security category)."
  }

  assert {
    condition     = output.zone_ids["privatelink.vaultcore.azure.net"] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-security/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
    error_message = "Expected vault zone_id to use existing_zone_id from service_overrides, not a created/looked-up zone."
  }

  assert {
    condition     = contains(keys(output.effective_subresource_zone_map), "managedhsm")
    error_message = "Expected managedhsm to also be active (from Security category)."
  }
}

run "vnet_links_created_for_managed_zones_only" {
  # VNet links are created for zones Terraform manages (create_zone=true).
  # Zones referenced with create_zone=false (data source) or existing_zone_id get no link.
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    enabled_services = {
      blob = true  # create_zone=true → link created
      file = false # create_zone=false → data source, no link
    }
    service_overrides = {}
    vnet_links = {
      dns_vnet = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-connectivity/providers/Microsoft.Network/virtualNetworks/vnet-dns"
    }
  }

  assert {
    condition     = length(output.vnet_link_ids) == 1
    error_message = "Expected exactly 1 VNet link (only for blob, which has create_zone=true). file uses data source so no link should be created."
  }

  assert {
    condition     = contains(keys(output.vnet_link_ids), "privatelink-blob-core-windows-net-dns_vnet")
    error_message = "Expected VNet link key 'privatelink-blob-core-windows-net-dns_vnet' to exist."
  }
}
