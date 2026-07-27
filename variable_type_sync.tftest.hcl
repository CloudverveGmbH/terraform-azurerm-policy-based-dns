# variable_type_sync.tftest.hcl
#
# Purpose: ensure the typed object definitions for enabled_services and
# enabled_categories stay in sync with the service catalog.
#
# Two complementary checks per run:
#
#   1. TYPE CHECK (compile-time):
#      Every catalog key is passed as an attribute in the typed object literal.
#      If a key was added to the catalog but not to the variable's object type,
#      Terraform's type checker raises an error before any assert is evaluated.
#
#   2. SET COMPARISON (runtime, dynamic):
#      The plan output.catalog_service_keys lists every key in local.service_catalog.
#      We compare it against the keys actually present in effective_subresource_zone_map.
#      If a catalog key is missing from the variable type it won't appear in the map,
#      causing the set comparison to fail — no hardcoded counts to maintain.

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

# ---------------------------------------------------------------------------
# enabled_services: every catalog service key must be a valid object attribute.
# All set to false so no zones are created (data-source path only, uses mock).
# ---------------------------------------------------------------------------
run "enabled_services_type_covers_all_catalog_keys" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_categories             = null
    service_overrides              = {}

    # Every key in the service catalog — type error here means variables.tf is out of sync.
    enabled_services = {
      # Storage
      blob            = false
      blob_secondary  = false
      file            = false
      file_secondary  = false
      queue           = false
      queue_secondary = false
      table           = false
      table_secondary = false
      dfs             = false
      dfs_secondary   = false
      web             = false
      web_secondary   = false
      afs             = false
      managed_disks   = false
      elastic_san     = false
      azure_files     = false
      # Security
      vault            = false
      managedhsm       = false
      appconfiguration = false
      attestation      = false
      # Analytics
      amlworkspace         = false
      amlregistry          = false
      foundry_account      = false
      azure_openai         = false
      azure_ai_services    = false
      bot_directline       = false
      bot_token            = false
      dataexplorer_cluster = false
      synapse_sql          = false
      synapse_sqlondemand  = false
      synapse_dev          = false
      synapse_web          = false
      eventhubs_namespace  = false
      servicebus_namespace = false
      datafactory_factory  = false
      datafactory_portal   = false
      hdinsight_gateway    = false
      powerbi_tenant       = false
      powerbi_dedicated    = false
      powerbi_powerquery   = false
      databricks           = false
      fabric_workspace     = false
      # Compute
      batch_account         = false
      batch_nodemgmt        = false
      avd_global            = false
      avd_feed              = false
      avd_connection        = false
      aks                   = false
      aks_gwc               = false
      aks_weu               = false
      containerapps         = false
      containerapps_gwc     = false
      containerapps_weu     = false
      acr                   = false
      acr_data              = false
      acr_data_gwc          = false
      acr_data_weu          = false
      containerinstance_gwc = false
      containerinstance_weu = false
      # Databases
      sql_server             = false
      sql_managed_instance   = false
      cosmosdb_sql           = false
      cosmosdb_mongodb       = false
      cosmosdb_cassandra     = false
      cosmosdb_gremlin       = false
      cosmosdb_table         = false
      cosmosdb_analytical    = false
      cosmosdb_postgres      = false
      cosmosdb_mongodb_vcore = false
      postgres_single        = false
      postgres_flexible      = false
      mysql_single           = false
      mysql_flexible         = false
      mariadb                = false
      redis_cache            = false
      redis_enterprise       = false
      managed_redis          = false
      # Hybrid
      arc_his         = false
      arc_guestconfig = false
      arc_k8s         = false
      # IoT
      iothub            = false
      iothub_servicebus = false
      iot_dps           = false
      device_update     = false
      iot_central       = false
      digital_twins     = false
      # Media
      media_keydelivery       = false
      media_liveevent         = false
      media_streamingendpoint = false
      video_indexer           = false
      # Management
      azuremonitor                 = false
      azuremonitor_oms             = false
      azuremonitor_ods             = false
      azuremonitor_agentsvc        = false
      azuremonitor_blob            = false
      managed_prometheus           = false
      automation_webhook           = false
      automation_dsc               = false
      backup_azurebackup           = false
      backup_azurebackup_secondary = false
      siterecovery                 = false
      migrate_default              = false
      migrate_assessment           = false
      grafana                      = false
      eventgrid_topic              = false
      eventgrid_domain             = false
      eventgrid_namespace          = false
      eventgrid_topicspace         = false
      eventgrid_partnernamespace   = false
      apim_gateway                 = false
      apim_portal                  = false
      healthcare_workspace         = false
      healthcare_dicom             = false
      purview_account              = false
      purview_portal               = false
      purview_platform             = false
      # Web
      searchservice   = false
      relay_namespace = false
      webapp          = false
      webapp_scm      = false
      signalr         = false
      staticwebapp    = false
      maps_account    = false
      webpubsub       = false
      # Special
      resource_manager = false
    }
  }

  # Dynamic set comparison: catches catalog keys added without updating variables.tf.
  # No hardcoded count — self-adjusts as the catalog grows.
  assert {
    condition     = toset(keys(output.effective_subresource_zone_map)) == toset(output.catalog_service_keys)
    error_message = "enabled_services object type is out of sync with the service catalog. Missing in variable type: ${join(", ", setsubtract(toset(output.catalog_service_keys), toset(keys(output.effective_subresource_zone_map))))}. Extra in variable type (not in catalog): ${join(", ", setsubtract(toset(keys(output.effective_subresource_zone_map)), toset(output.catalog_service_keys)))}."
  }
}

# ---------------------------------------------------------------------------
# enabled_categories: every non-Special catalog category must be a valid
# object attribute.  All set to false (reference existing zones, mock path).
# ---------------------------------------------------------------------------
run "enabled_categories_type_covers_all_catalog_categories" {
  command = plan

  variables {
    location                       = "germanywestcentral"
    region_code                    = "gwc"
    dns_resource_group_name        = "rg-dns"
    policy_definition_name         = "test-def"
    policy_definition_display_name = "test-def"
    policy_assignment_scope_ids    = {}
    enabled_services               = null
    service_overrides              = {}

    # Every non-Special category — type error here means variables.tf is out of sync.
    enabled_categories = {
      Analytics  = false
      Compute    = false
      Databases  = false
      Hybrid     = false
      IoT        = false
      Management = false
      Media      = false
      Security   = false
      Storage    = false
      Web        = false
    }
  }

  # Dynamic set comparison against non-Special catalog keys — no hardcoded count.
  assert {
    condition     = toset(keys(output.effective_subresource_zone_map)) == toset(output.catalog_non_special_service_keys)
    error_message = "enabled_categories object type is out of sync with the service catalog. Missing non-Special keys: ${join(", ", setsubtract(toset(output.catalog_non_special_service_keys), toset(keys(output.effective_subresource_zone_map))))}. Unexpected extra keys: ${join(", ", setsubtract(toset(keys(output.effective_subresource_zone_map)), toset(output.catalog_non_special_service_keys)))}."
  }
}
