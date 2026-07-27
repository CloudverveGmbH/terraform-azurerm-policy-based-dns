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
  description = "Category selectors with create_zone flag. Example: { Storage = true, Web = false }. The 'Special' category is intentionally excluded — use enabled_services = { resource_manager = true } for explicit opt-in."
  type = object({
    Analytics  = optional(bool)
    Compute    = optional(bool)
    Databases  = optional(bool)
    Hybrid     = optional(bool)
    IoT        = optional(bool)
    Management = optional(bool)
    Media      = optional(bool)
    Security   = optional(bool)
    Storage    = optional(bool)
    Web        = optional(bool)
  })
  default  = null
  nullable = true
}

variable "enabled_services" {
  description = "Explicit service selectors with create_zone flag. Overrides enabled_categories for matching service keys. Example: { staticwebapp = true }."
  type = object({
    # Storage
    blob            = optional(bool)
    blob_secondary  = optional(bool)
    file            = optional(bool)
    file_secondary  = optional(bool)
    queue           = optional(bool)
    queue_secondary = optional(bool)
    table           = optional(bool)
    table_secondary = optional(bool)
    dfs             = optional(bool)
    dfs_secondary   = optional(bool)
    web             = optional(bool)
    web_secondary   = optional(bool)
    afs             = optional(bool)
    managed_disks   = optional(bool)
    elastic_san     = optional(bool)
    azure_files     = optional(bool)
    # Security
    vault            = optional(bool)
    managedhsm       = optional(bool)
    appconfiguration = optional(bool)
    attestation      = optional(bool)
    # Analytics
    amlworkspace         = optional(bool)
    amlregistry          = optional(bool)
    foundry_account      = optional(bool)
    azure_openai         = optional(bool)
    azure_ai_services    = optional(bool)
    bot_directline       = optional(bool)
    bot_token            = optional(bool)
    dataexplorer_cluster = optional(bool)
    synapse_sql          = optional(bool)
    synapse_sqlondemand  = optional(bool)
    synapse_dev          = optional(bool)
    synapse_web          = optional(bool)
    eventhubs_namespace  = optional(bool)
    servicebus_namespace = optional(bool)
    datafactory_factory  = optional(bool)
    datafactory_portal   = optional(bool)
    hdinsight_gateway    = optional(bool)
    powerbi_tenant       = optional(bool)
    powerbi_dedicated    = optional(bool)
    powerbi_powerquery   = optional(bool)
    databricks           = optional(bool)
    fabric_workspace     = optional(bool)
    # Compute
    batch_account         = optional(bool)
    batch_nodemgmt        = optional(bool)
    avd_global            = optional(bool)
    avd_feed              = optional(bool)
    avd_connection        = optional(bool)
    aks                   = optional(bool)
    aks_gwc               = optional(bool)
    aks_weu               = optional(bool)
    containerapps         = optional(bool)
    containerapps_gwc     = optional(bool)
    containerapps_weu     = optional(bool)
    acr                   = optional(bool)
    acr_data              = optional(bool)
    acr_data_gwc          = optional(bool)
    acr_data_weu          = optional(bool)
    containerinstance_gwc = optional(bool)
    containerinstance_weu = optional(bool)
    # Databases
    sql_server             = optional(bool)
    sql_managed_instance   = optional(bool)
    cosmosdb_sql           = optional(bool)
    cosmosdb_mongodb       = optional(bool)
    cosmosdb_cassandra     = optional(bool)
    cosmosdb_gremlin       = optional(bool)
    cosmosdb_table         = optional(bool)
    cosmosdb_analytical    = optional(bool)
    cosmosdb_postgres      = optional(bool)
    cosmosdb_mongodb_vcore = optional(bool)
    postgres_single        = optional(bool)
    postgres_flexible      = optional(bool)
    mysql_single           = optional(bool)
    mysql_flexible         = optional(bool)
    mariadb                = optional(bool)
    redis_cache            = optional(bool)
    redis_enterprise       = optional(bool)
    managed_redis          = optional(bool)
    # Hybrid
    arc_his         = optional(bool)
    arc_guestconfig = optional(bool)
    arc_k8s         = optional(bool)
    # IoT
    iothub            = optional(bool)
    iothub_servicebus = optional(bool)
    iot_dps           = optional(bool)
    device_update     = optional(bool)
    iot_central       = optional(bool)
    digital_twins     = optional(bool)
    # Media
    media_keydelivery       = optional(bool)
    media_liveevent         = optional(bool)
    media_streamingendpoint = optional(bool)
    video_indexer           = optional(bool)
    # Management
    azuremonitor                 = optional(bool)
    azuremonitor_oms             = optional(bool)
    azuremonitor_ods             = optional(bool)
    azuremonitor_agentsvc        = optional(bool)
    azuremonitor_blob            = optional(bool)
    managed_prometheus           = optional(bool)
    automation_webhook           = optional(bool)
    automation_dsc               = optional(bool)
    backup_azurebackup           = optional(bool)
    backup_azurebackup_secondary = optional(bool)
    siterecovery                 = optional(bool)
    migrate_default              = optional(bool)
    migrate_assessment           = optional(bool)
    grafana                      = optional(bool)
    eventgrid_topic              = optional(bool)
    eventgrid_domain             = optional(bool)
    eventgrid_namespace          = optional(bool)
    eventgrid_topicspace         = optional(bool)
    eventgrid_partnernamespace   = optional(bool)
    apim_gateway                 = optional(bool)
    apim_portal                  = optional(bool)
    healthcare_workspace         = optional(bool)
    healthcare_dicom             = optional(bool)
    purview_account              = optional(bool)
    purview_portal               = optional(bool)
    purview_platform             = optional(bool)
    # Web
    searchservice   = optional(bool)
    relay_namespace = optional(bool)
    webapp          = optional(bool)
    webapp_scm      = optional(bool)
    signalr         = optional(bool)
    staticwebapp    = optional(bool)
    maps_account    = optional(bool)
    webpubsub       = optional(bool)
    # Special (not activatable via enabled_categories; must be opted in explicitly)
    resource_manager = optional(bool)
  })
  default  = null
  nullable = true
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
