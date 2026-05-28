locals {
  service_catalog = {
    # ---------------------------------------------------------------------------
    # Storage
    # ---------------------------------------------------------------------------
    blob            = { category = "Storage", group_id = "blob", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.blob.core.windows.net" }
    blob_secondary  = { category = "Storage", group_id = "blob_secondary", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.blob.core.windows.net" }
    file            = { category = "Storage", group_id = "file", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.file.core.windows.net" }
    file_secondary  = { category = "Storage", group_id = "file_secondary", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.file.core.windows.net" }
    queue           = { category = "Storage", group_id = "queue", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.queue.core.windows.net" }
    queue_secondary = { category = "Storage", group_id = "queue_secondary", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.queue.core.windows.net" }
    table           = { category = "Storage", group_id = "table", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.table.core.windows.net" }
    table_secondary = { category = "Storage", group_id = "table_secondary", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.table.core.windows.net" }
    dfs             = { category = "Storage", group_id = "dfs", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.dfs.core.windows.net" }
    dfs_secondary   = { category = "Storage", group_id = "dfs_secondary", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.dfs.core.windows.net" }
    web             = { category = "Storage", group_id = "web", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.web.core.windows.net" }
    web_secondary   = { category = "Storage", group_id = "web_secondary", resource_type = "Microsoft.Storage/storageAccounts", zone_name = "privatelink.web.core.windows.net" }
    afs             = { category = "Storage", group_id = "afs", resource_type = "Microsoft.StorageSync/storageSyncServices", zone_name = "privatelink.afs.azure.net" }
    managed_disks   = { category = "Storage", group_id = "disks", resource_type = "Microsoft.Compute/diskAccesses", zone_name = "privatelink.blob.core.windows.net" }
    elastic_san     = { category = "Storage", group_id = "volumegroup", resource_type = "Microsoft.ElasticSan/elasticSans", zone_name = "privatelink.blob.core.windows.net" }
    azure_files     = { category = "Storage", group_id = "FileShare", resource_type = "Microsoft.FileShares/fileShares", zone_name = "privatelink.file.core.windows.net" }

    # ---------------------------------------------------------------------------
    # Security
    # ---------------------------------------------------------------------------
    vault            = { category = "Security", group_id = "vault", resource_type = "Microsoft.KeyVault/vaults", zone_name = "privatelink.vaultcore.azure.net" }
    managedhsm       = { category = "Security", group_id = "managedhsm", resource_type = "Microsoft.KeyVault/managedHSMs", zone_name = "privatelink.managedhsm.azure.net" }
    appconfiguration = { category = "Security", group_id = "configurationStores", resource_type = "Microsoft.AppConfiguration/configurationStores", zone_name = "privatelink.azconfig.io" }
    attestation      = { category = "Security", group_id = "standard", resource_type = "Microsoft.Attestation/attestationProviders", zone_name = "privatelink.attest.azure.net" }

    # ---------------------------------------------------------------------------
    # Analytics  (MS doc sections: AI+ML, Analytics)
    # ---------------------------------------------------------------------------
    amlworkspace         = { category = "Analytics", group_id = "amlworkspace", resource_type = "Microsoft.MachineLearningServices/workspaces", zone_name = "privatelink.api.azureml.ms" }
    amlregistry          = { category = "Analytics", group_id = "amlregistry", resource_type = "Microsoft.MachineLearningServices/registries", zone_name = "privatelink.api.azureml.ms" }
    foundry_account      = { category = "Analytics", group_id = "account", resource_type = "Microsoft.CognitiveServices/accounts", zone_name = "privatelink.cognitiveservices.azure.com" }
    azure_openai         = { category = "Analytics", group_id = "account", resource_type = "Microsoft.CognitiveServices/accounts", zone_name = "privatelink.openai.azure.com" }
    azure_ai_services    = { category = "Analytics", group_id = "account", resource_type = "Microsoft.CognitiveServices/accounts", zone_name = "privatelink.services.ai.azure.com" }
    bot_directline       = { category = "Analytics", group_id = "Bot", resource_type = "Microsoft.BotService/botServices", zone_name = "privatelink.directline.botframework.com" }
    bot_token            = { category = "Analytics", group_id = "Token", resource_type = "Microsoft.BotService/botServices", zone_name = "privatelink.token.botframework.com" }
    dataexplorer_cluster = { category = "Analytics", group_id = "cluster", resource_type = "Microsoft.Kusto/clusters", zone_name = "privatelink.{location}.kusto.windows.net" }
    synapse_sql          = { category = "Analytics", group_id = "Sql", resource_type = "Microsoft.Synapse/workspaces", zone_name = "privatelink.sql.azuresynapse.net" }
    synapse_sqlondemand  = { category = "Analytics", group_id = "SqlOnDemand", resource_type = "Microsoft.Synapse/workspaces", zone_name = "privatelink.sql.azuresynapse.net" }
    synapse_dev          = { category = "Analytics", group_id = "Dev", resource_type = "Microsoft.Synapse/workspaces", zone_name = "privatelink.dev.azuresynapse.net" }
    synapse_web          = { category = "Analytics", group_id = "Web", resource_type = "Microsoft.Synapse/privateLinkHubs", zone_name = "privatelink.azuresynapse.net" }
    eventhubs_namespace  = { category = "Analytics", group_id = "namespace", resource_type = "Microsoft.EventHub/namespaces", zone_name = "privatelink.servicebus.windows.net" }
    servicebus_namespace = { category = "Analytics", group_id = "namespace", resource_type = "Microsoft.ServiceBus/namespaces", zone_name = "privatelink.servicebus.windows.net" }
    datafactory_factory  = { category = "Analytics", group_id = "dataFactory", resource_type = "Microsoft.DataFactory/factories", zone_name = "privatelink.datafactory.azure.net" }
    datafactory_portal   = { category = "Analytics", group_id = "portal", resource_type = "Microsoft.DataFactory/factories", zone_name = "privatelink.adf.azure.com" }
    hdinsight_gateway    = { category = "Analytics", group_id = "gateway headnode", resource_type = "Microsoft.HDInsight/clusters", zone_name = "privatelink.azurehdinsight.net" }
    powerbi_tenant       = { category = "Analytics", group_id = "tenant", resource_type = "Microsoft.PowerBI/privateLinkServicesForPowerBI", zone_name = "privatelink.analysis.windows.net" }
    powerbi_dedicated    = { category = "Analytics", group_id = "tenant", resource_type = "Microsoft.PowerBI/privateLinkServicesForPowerBI", zone_name = "privatelink.pbidedicated.windows.net" }
    powerbi_powerquery   = { category = "Analytics", group_id = "tenant", resource_type = "Microsoft.PowerBI/privateLinkServicesForPowerBI", zone_name = "privatelink.prod.powerquery.microsoft.com" }
    databricks           = { category = "Analytics", group_id = "databricks_ui_api", resource_type = "Microsoft.Databricks/workspaces", zone_name = "privatelink.azuredatabricks.net" }
    fabric_workspace     = { category = "Analytics", group_id = "workspace", resource_type = "Microsoft.Fabric/privateLinkServicesForFabric", zone_name = "privatelink.fabric.microsoft.com" }

    # ---------------------------------------------------------------------------
    # Compute  (MS doc sections: Compute, Containers)
    # ---------------------------------------------------------------------------
    batch_account  = { category = "Compute", group_id = "batchAccount", resource_type = "Microsoft.Batch/batchAccounts", zone_name = "privatelink.batch.azure.com" }
    batch_nodemgmt = { category = "Compute", group_id = "nodeManagement", resource_type = "Microsoft.Batch/batchAccounts", zone_name = "privatelink.batch.azure.com" }
    avd_global     = { category = "Compute", group_id = "global", resource_type = "Microsoft.DesktopVirtualization/workspaces", zone_name = "privatelink-global.wvd.microsoft.com" }
    avd_feed       = { category = "Compute", group_id = "feed", resource_type = "Microsoft.DesktopVirtualization/workspaces", zone_name = "privatelink.wvd.microsoft.com" }
    avd_connection = { category = "Compute", group_id = "connection", resource_type = "Microsoft.DesktopVirtualization/hostpools", zone_name = "privatelink.wvd.microsoft.com" }
    # AKS: use explicit regional keys (aks_gwc / aks_weu) or the dynamic key with {location}
    aks                   = { category = "Compute", group_id = "management", resource_type = "Microsoft.ContainerService/managedClusters", zone_name = "privatelink.{location}.azmk8s.io" }
    aks_gwc               = { category = "Compute", group_id = "management", resource_type = "Microsoft.ContainerService/managedClusters", zone_name = "privatelink.germanywestcentral.azmk8s.io" }
    aks_weu               = { category = "Compute", group_id = "management", resource_type = "Microsoft.ContainerService/managedClusters", zone_name = "privatelink.westeurope.azmk8s.io" }
    containerapps         = { category = "Compute", group_id = "managedEnvironments", resource_type = "Microsoft.App/managedEnvironments", zone_name = "privatelink.{location}.azurecontainerapps.io" }
    containerapps_gwc     = { category = "Compute", group_id = "managedEnvironments", resource_type = "Microsoft.App/managedEnvironments", zone_name = "privatelink.germanywestcentral.azurecontainerapps.io" }
    containerapps_weu     = { category = "Compute", group_id = "managedEnvironments", resource_type = "Microsoft.App/managedEnvironments", zone_name = "privatelink.westeurope.azurecontainerapps.io" }
    acr                   = { category = "Compute", group_id = "registry", resource_type = "Microsoft.ContainerRegistry/registries", zone_name = "privatelink.azurecr.io" }
    acr_data              = { category = "Compute", group_id = "registry", resource_type = "Microsoft.ContainerRegistry/registries", zone_name = "privatelink.{location}.data.privatelink.azurecr.io" }
    acr_data_gwc          = { category = "Compute", group_id = "registry", resource_type = "Microsoft.ContainerRegistry/registries", zone_name = "privatelink.germanywestcentral.data.privatelink.azurecr.io" }
    acr_data_weu          = { category = "Compute", group_id = "registry", resource_type = "Microsoft.ContainerRegistry/registries", zone_name = "privatelink.westeurope.data.privatelink.azurecr.io" }
    containerinstance_gwc = { category = "Compute", group_id = "containerGroup", resource_type = "Microsoft.ContainerInstance/containerGroups", zone_name = "privatelink.germanywestcentral.azurecontainer.io" }
    containerinstance_weu = { category = "Compute", group_id = "containerGroup", resource_type = "Microsoft.ContainerInstance/containerGroups", zone_name = "privatelink.westeurope.azurecontainer.io" }

    # ---------------------------------------------------------------------------
    # Databases
    # ---------------------------------------------------------------------------
    sql_server = { category = "Databases", group_id = "sqlServer", resource_type = "Microsoft.Sql/servers", zone_name = "privatelink.database.windows.net" }
    # sql_managed_instance uses a per-instance {dnsPrefix} – override zone_name via service_overrides
    sql_managed_instance   = { category = "Databases", group_id = "managedInstance", resource_type = "Microsoft.Sql/managedInstances", zone_name = "privatelink.{dnsPrefix}.database.windows.net" }
    cosmosdb_sql           = { category = "Databases", group_id = "Sql", resource_type = "Microsoft.DocumentDB/databaseAccounts", zone_name = "privatelink.documents.azure.com" }
    cosmosdb_mongodb       = { category = "Databases", group_id = "MongoDB", resource_type = "Microsoft.DocumentDB/databaseAccounts", zone_name = "privatelink.mongo.cosmos.azure.com" }
    cosmosdb_cassandra     = { category = "Databases", group_id = "Cassandra", resource_type = "Microsoft.DocumentDB/databaseAccounts", zone_name = "privatelink.cassandra.cosmos.azure.com" }
    cosmosdb_gremlin       = { category = "Databases", group_id = "Gremlin", resource_type = "Microsoft.DocumentDB/databaseAccounts", zone_name = "privatelink.gremlin.cosmos.azure.com" }
    cosmosdb_table         = { category = "Databases", group_id = "Table", resource_type = "Microsoft.DocumentDB/databaseAccounts", zone_name = "privatelink.table.cosmos.azure.com" }
    cosmosdb_analytical    = { category = "Databases", group_id = "Analytical", resource_type = "Microsoft.DocumentDB/databaseAccounts", zone_name = "privatelink.analytics.cosmos.azure.com" }
    cosmosdb_postgres      = { category = "Databases", group_id = "coordinator", resource_type = "Microsoft.DBforPostgreSQL/serverGroupsv2", zone_name = "privatelink.postgres.cosmos.azure.com" }
    cosmosdb_mongodb_vcore = { category = "Databases", group_id = "MongoCluster", resource_type = "Microsoft.DocumentDB/mongoClusters", zone_name = "privatelink.mongocluster.cosmos.azure.com" }
    postgres_single        = { category = "Databases", group_id = "postgresqlServer", resource_type = "Microsoft.DBforPostgreSQL/servers", zone_name = "privatelink.postgres.database.azure.com" }
    postgres_flexible      = { category = "Databases", group_id = "postgresqlServer", resource_type = "Microsoft.DBforPostgreSQL/flexibleServers", zone_name = "privatelink.postgres.database.azure.com" }
    mysql_single           = { category = "Databases", group_id = "mysqlServer", resource_type = "Microsoft.DBforMySQL/servers", zone_name = "privatelink.mysql.database.azure.com" }
    mysql_flexible         = { category = "Databases", group_id = "mysqlServer", resource_type = "Microsoft.DBforMySQL/flexibleServers", zone_name = "privatelink.mysql.database.azure.com" }
    mariadb                = { category = "Databases", group_id = "mariadbServer", resource_type = "Microsoft.DBforMariaDB/servers", zone_name = "privatelink.mariadb.database.azure.com" }
    redis_cache            = { category = "Databases", group_id = "redisCache", resource_type = "Microsoft.Cache/Redis", zone_name = "privatelink.redis.cache.windows.net" }
    redis_enterprise       = { category = "Databases", group_id = "redisEnterprise", resource_type = "Microsoft.Cache/RedisEnterprise", zone_name = "privatelink.redisenterprise.cache.azure.net" }
    managed_redis          = { category = "Databases", group_id = "redisEnterprise", resource_type = "Microsoft.Cache/RedisEnterprise", zone_name = "privatelink.redis.azure.net" }

    # ---------------------------------------------------------------------------
    # Hybrid
    # ---------------------------------------------------------------------------
    arc_his         = { category = "Hybrid", group_id = "hybridcompute", resource_type = "Microsoft.HybridCompute/privateLinkScopes", zone_name = "privatelink.his.arc.azure.com" }
    arc_guestconfig = { category = "Hybrid", group_id = "hybridcompute", resource_type = "Microsoft.HybridCompute/privateLinkScopes", zone_name = "privatelink.guestconfiguration.azure.com" }
    arc_k8s         = { category = "Hybrid", group_id = "hybridcompute", resource_type = "Microsoft.HybridCompute/privateLinkScopes", zone_name = "privatelink.dp.kubernetesconfiguration.azure.com" }

    # ---------------------------------------------------------------------------
    # IoT
    # ---------------------------------------------------------------------------
    iothub            = { category = "IoT", group_id = "iotHub", resource_type = "Microsoft.Devices/IotHubs", zone_name = "privatelink.azure-devices.net" }
    iothub_servicebus = { category = "IoT", group_id = "iotHub", resource_type = "Microsoft.Devices/IotHubs", zone_name = "privatelink.servicebus.windows.net" }
    iot_dps           = { category = "IoT", group_id = "iotDps", resource_type = "Microsoft.Devices/ProvisioningServices", zone_name = "privatelink.azure-devices-provisioning.net" }
    device_update     = { category = "IoT", group_id = "DeviceUpdate", resource_type = "Microsoft.DeviceUpdate/accounts", zone_name = "privatelink.api.adu.microsoft.com" }
    iot_central       = { category = "IoT", group_id = "iotApp", resource_type = "Microsoft.IoTCentral/IoTApps", zone_name = "privatelink.azureiotcentral.com" }
    digital_twins     = { category = "IoT", group_id = "API", resource_type = "Microsoft.DigitalTwins/digitalTwinsInstances", zone_name = "privatelink.digitaltwins.azure.net" }

    # ---------------------------------------------------------------------------
    # Media
    # ---------------------------------------------------------------------------
    media_keydelivery       = { category = "Media", group_id = "keydelivery", resource_type = "Microsoft.Media/mediaservices", zone_name = "privatelink.media.azure.net" }
    media_liveevent         = { category = "Media", group_id = "liveevent", resource_type = "Microsoft.Media/mediaservices", zone_name = "privatelink.media.azure.net" }
    media_streamingendpoint = { category = "Media", group_id = "streamingendpoint", resource_type = "Microsoft.Media/mediaservices", zone_name = "privatelink.media.azure.net" }
    video_indexer           = { category = "Media", group_id = "account", resource_type = "Microsoft.VideoIndexer/accounts", zone_name = "privatelink.api.videoindexer.ai" }

    # ---------------------------------------------------------------------------
    # Management  (MS doc sections: Management and Governance, Integration)
    # ---------------------------------------------------------------------------
    azuremonitor                 = { category = "Management", group_id = "azuremonitor", resource_type = "Microsoft.Insights/privateLinkScopes", zone_name = "privatelink.monitor.azure.com" }
    azuremonitor_oms             = { category = "Management", group_id = "azuremonitor", resource_type = "Microsoft.Insights/privateLinkScopes", zone_name = "privatelink.oms.opinsights.azure.com" }
    azuremonitor_ods             = { category = "Management", group_id = "azuremonitor", resource_type = "Microsoft.Insights/privateLinkScopes", zone_name = "privatelink.ods.opinsights.azure.com" }
    azuremonitor_agentsvc        = { category = "Management", group_id = "azuremonitor", resource_type = "Microsoft.Insights/privateLinkScopes", zone_name = "privatelink.agentsvc.azure-automation.net" }
    azuremonitor_blob            = { category = "Management", group_id = "azuremonitor", resource_type = "Microsoft.Insights/privateLinkScopes", zone_name = "privatelink.blob.core.windows.net" }
    managed_prometheus           = { category = "Management", group_id = "prometheusMetrics", resource_type = "Microsoft.Monitor/accounts", zone_name = "privatelink.{location}.prometheus.monitor.azure.com" }
    automation_webhook           = { category = "Management", group_id = "Webhook", resource_type = "Microsoft.Automation/automationAccounts", zone_name = "privatelink.azure-automation.net" }
    automation_dsc               = { category = "Management", group_id = "DSCAndHybridWorker", resource_type = "Microsoft.Automation/automationAccounts", zone_name = "privatelink.azure-automation.net" }
    backup_azurebackup           = { category = "Management", group_id = "AzureBackup", resource_type = "Microsoft.RecoveryServices/vaults", zone_name = "privatelink.{regionCode}.backup.windowsazure.com" }
    backup_azurebackup_secondary = { category = "Management", group_id = "AzureBackup_secondary", resource_type = "Microsoft.RecoveryServices/vaults", zone_name = "privatelink.{regionCode}.backup.windowsazure.com" }
    siterecovery                 = { category = "Management", group_id = "AzureSiteRecovery", resource_type = "Microsoft.RecoveryServices/vaults", zone_name = "privatelink.siterecovery.windowsazure.com" }
    migrate_default              = { category = "Management", group_id = "Default", resource_type = "Microsoft.Migrate/migrateProjects", zone_name = "privatelink.prod.migration.windowsazure.com" }
    migrate_assessment           = { category = "Management", group_id = "Default", resource_type = "Microsoft.Migrate/assessmentProjects", zone_name = "privatelink.prod.migration.windowsazure.com" }
    resource_manager             = { category = "Management", group_id = "ResourceManagement", resource_type = "Microsoft.Authorization/resourceManagementPrivateLinks", zone_name = "privatelink.azure.com" }
    grafana                      = { category = "Management", group_id = "grafana", resource_type = "Microsoft.Dashboard/grafana", zone_name = "privatelink.grafana.azure.com" }
    eventgrid_topic              = { category = "Management", group_id = "topic", resource_type = "Microsoft.EventGrid/topics", zone_name = "privatelink.eventgrid.azure.net" }
    eventgrid_domain             = { category = "Management", group_id = "domain", resource_type = "Microsoft.EventGrid/domains", zone_name = "privatelink.eventgrid.azure.net" }
    eventgrid_namespace          = { category = "Management", group_id = "topic", resource_type = "Microsoft.EventGrid/namespaces", zone_name = "privatelink.eventgrid.azure.net" }
    eventgrid_topicspace         = { category = "Management", group_id = "topicSpace", resource_type = "Microsoft.EventGrid/namespaces", zone_name = "privatelink.ts.eventgrid.azure.net" }
    eventgrid_partnernamespace   = { category = "Management", group_id = "partnernamespace", resource_type = "Microsoft.EventGrid/partnerNamespaces", zone_name = "privatelink.eventgrid.azure.net" }
    apim_gateway                 = { category = "Management", group_id = "Gateway", resource_type = "Microsoft.ApiManagement/service", zone_name = "privatelink.azure-api.net" }
    apim_portal                  = { category = "Management", group_id = "Portal", resource_type = "Microsoft.ApiManagement/service", zone_name = "privatelink.azure-api.net" }
    healthcare_workspace         = { category = "Management", group_id = "healthcareworkspace", resource_type = "Microsoft.HealthcareApis/workspaces", zone_name = "privatelink.azurehealthcareapis.com" }
    healthcare_dicom             = { category = "Management", group_id = "healthcareworkspace", resource_type = "Microsoft.HealthcareApis/workspaces", zone_name = "privatelink.dicom.azurehealthcareapis.com" }
    purview_account              = { category = "Management", group_id = "account", resource_type = "Microsoft.Purview/accounts", zone_name = "privatelink.purview.azure.com" }
    purview_portal               = { category = "Management", group_id = "portal", resource_type = "Microsoft.Purview/accounts", zone_name = "privatelink.purviewstudio.azure.com" }
    purview_platform             = { category = "Management", group_id = "platform", resource_type = "Microsoft.Purview/accounts", zone_name = "privatelink.purview-service.microsoft.com" }

    # ---------------------------------------------------------------------------
    # Web  (MS doc section: Web)
    # ---------------------------------------------------------------------------
    searchservice   = { category = "Web", group_id = "searchService", resource_type = "Microsoft.Search/searchServices", zone_name = "privatelink.search.windows.net" }
    relay_namespace = { category = "Web", group_id = "namespace", resource_type = "Microsoft.Relay/namespaces", zone_name = "privatelink.servicebus.windows.net" }
    webapp          = { category = "Web", group_id = "sites", resource_type = "Microsoft.Web/sites", zone_name = "privatelink.azurewebsites.net" }
    webapp_scm      = { category = "Web", group_id = "sites", resource_type = "Microsoft.Web/sites", zone_name = "scm.privatelink.azurewebsites.net" }
    signalr         = { category = "Web", group_id = "signalr", resource_type = "Microsoft.SignalRService/SignalR", zone_name = "privatelink.service.signalr.net" }
    staticwebapp    = { category = "Web", group_id = "staticSites", resource_type = "Microsoft.Web/staticSites", zone_name = "privatelink.azurestaticapps.net" }
    maps_account    = { category = "Web", group_id = "account", resource_type = "Microsoft.Maps/accounts", zone_name = "privatelink.account.maps.azure.com" }
    webpubsub       = { category = "Web", group_id = "webpubsub", resource_type = "Microsoft.SignalRService/WebPubSub", zone_name = "privatelink.webpubsub.azure.com" }
  }

  category_service_keys = {
    for category in toset([for _, svc in local.service_catalog : svc.category]) :
    category => [for service_key, svc in local.service_catalog : service_key if svc.category == category]
  }

  catalog_binding_key_by_service = {
    for service_key, svc in local.service_catalog :
    service_key => "${lower(svc.resource_type)}|${lower(svc.group_id)}|${lower(svc.zone_name)}"
  }

  duplicate_catalog_bindings = [
    for binding_key in toset(values(local.catalog_binding_key_by_service)) :
    binding_key
    if length([
      for _, other_binding_key in local.catalog_binding_key_by_service : other_binding_key
      if other_binding_key == binding_key
    ]) > 1
  ]

  duplicate_catalog_binding_details = [
    for binding_key in sort(local.duplicate_catalog_bindings) :
    "${binding_key} -> ${join(", ", sort([for service_key, key in local.catalog_binding_key_by_service : service_key if key == binding_key]))}"
  ]

  normalized_enabled_categories = coalesce(var.enabled_categories, {})
  normalized_enabled_services   = coalesce(var.enabled_services, {})

  unknown_enabled_categories = [
    for category, _ in local.normalized_enabled_categories : category
    if !contains(keys(local.category_service_keys), category)
  ]

  # Any key in service_overrides with existing_zone_id is auto-activated (create_zone = false).
  # This covers both catalog keys (e.g. aks) and fully custom keys — no enabled_services entry required.
  override_auto_activated = {
    for key, override in coalesce(var.service_overrides, {}) :
    key => override
    if try(override.existing_zone_id, null) != null
  }

  # Keys in service_overrides that are NOT in the catalog, have no existing_zone_id auto-activation,
  # but carry enough data to be treated as fully custom entries (group_id + resource_type + zone_name).
  custom_override_entries = {
    for key, override in coalesce(var.service_overrides, {}) :
    key => override
    if !contains(keys(local.service_catalog), key)
    && !contains(keys(local.override_auto_activated), key)
    && try(override.group_id, null) != null
    && try(override.resource_type, null) != null
    && try(override.zone_name, null) != null
  }

  # Keys in service_overrides that are NOT in the catalog, NOT auto-activated via existing_zone_id,
  # and do NOT carry enough data — likely typos or incomplete configs.
  incomplete_custom_override_entries = [
    for key, override in coalesce(var.service_overrides, {}) : key
    if !contains(keys(local.service_catalog), key)
    && !contains(keys(local.override_auto_activated), key)
    && !contains(keys(local.custom_override_entries), key)
  ]

  unknown_enabled_services = [
    for service_key, _ in local.normalized_enabled_services : service_key
    if !contains(keys(local.service_catalog), service_key)
    && !contains(keys(local.override_auto_activated), service_key)
    && !contains(keys(local.custom_override_entries), service_key)
  ]

  selected_from_categories = length(local.normalized_enabled_categories) > 0 ? merge([
    for category, create_zone in local.normalized_enabled_categories : {
      for service_key in local.category_service_keys[category] : service_key => create_zone
    }
  ]...) : {}

  # override_auto_activated and custom_override_entries are always activated with create_zone = false.
  # explicit enabled_services / enabled_categories entries override that if needed.
  selected_service_create_zone = merge(
    { for key, _ in local.override_auto_activated : key => false },
    { for key, _ in local.custom_override_entries : key => false },
    local.selected_from_categories,
    local.normalized_enabled_services
  )

  computed_subresource_zone_map = {
    for service_key, create_zone in local.selected_service_create_zone :
    service_key => merge(
      # For custom override entries (not in catalog), the base is empty —
      # all required fields must come from service_overrides.
      try(local.service_catalog[service_key], {}),
      # Strip null-valued fields from service_overrides so optional(string) defaults
      # do not overwrite non-null catalog values (e.g. group_id, resource_type).
      { for k, v in try(var.service_overrides[service_key], {}) : k => v if v != null },
      {
        zone_name = replace(
          replace(
            replace(
              coalesce(
                try(var.service_overrides[service_key].zone_name, null),
                try(local.service_catalog[service_key].zone_name, null),
                # Derive zone_name from existing_zone_id last path segment as last resort
                # (e.g. ".../privateDnsZones/privatelink.westeurope.azmk8s.io" → the zone name)
                try(reverse(split("/", var.service_overrides[service_key].existing_zone_id))[0], null)
              ),
              "{location}",
              lower(var.location)
            ),
            "{regionName}",
            lower(var.location)
          ),
          "{regionCode}",
          var.region_code
        )
        create_zone = create_zone
      }
    )
  }

  effective_subresource_zone_map = local.computed_subresource_zone_map
}

check "known_enabled_categories" {
  assert {
    condition     = length(local.unknown_enabled_categories) == 0
    error_message = "Unknown category key(s) in enabled_categories: ${join(", ", local.unknown_enabled_categories)}. Valid categories: ${join(", ", sort(keys(local.category_service_keys)))}"
  }
}

check "known_enabled_services" {
  assert {
    condition     = length(local.unknown_enabled_services) == 0
    error_message = "Unknown service key(s) in enabled_services: ${join(", ", local.unknown_enabled_services)}"
  }
}

check "complete_custom_override_entries" {
  assert {
    condition     = length(local.incomplete_custom_override_entries) == 0
    error_message = "service_overrides key(s) not found in catalog and missing required fields (group_id, resource_type, and zone_name or existing_zone_id): ${join(", ", local.incomplete_custom_override_entries)}. Either fix the typo, add group_id + resource_type + zone_name/existing_zone_id, or activate the key via enabled_services."
  }
}

check "unique_catalog_bindings" {
  assert {
    condition     = length(local.duplicate_catalog_bindings) == 0
    error_message = "Duplicate catalog binding(s) found (resource_type|group_id|zone_name): ${join("; ", local.duplicate_catalog_binding_details)}"
  }
}

