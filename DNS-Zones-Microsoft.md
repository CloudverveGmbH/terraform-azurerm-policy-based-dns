---
title: Azure Private Endpoint private DNS zone values | Microsoft Learn
canonicalUrl: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns
updated_at: 2026-05-07T22:15:00.0000000Z
---

# Azure Private Endpoint private DNS zone values | Microsoft Learn

It's important to correctly configure your DNS settings to resolve the private endpoint IP address to the fully qualified domain name (FQDN) of the connection string.

Existing Microsoft Azure services might already have a DNS configuration for a public endpoint. This configuration must be overridden to connect using your private endpoint.

The network interface associated with the private endpoint contains the information to configure your DNS. The network interface information includes FQDN and private IP addresses for your private link resource.

You can use the following options to configure your DNS settings for private endpoints:

- **Use the host file (only recommended for testing)**. You can use the host file on a virtual machine to override the DNS.
- **Use a private DNS zone**. You can use [Private DNS Zones](../dns/private-dns-privatednszone) to override the DNS resolution for a private endpoint. A private DNS zone can be linked to your virtual network to resolve specific domains.
- **Use Azure Private Resolver (optional)**. You can use Azure Private Resolver to override the DNS resolution for a private link resource. For more information about Azure Private Resolver, see [What is Azure Private Resolver?](../dns/dns-private-resolver-overview)

Caution

- It's not recommended to override a zone that's actively in use to resolve public endpoints. Connections to resources won't be able to resolve correctly without DNS forwarding to the public DNS. To avoid issues, create a different domain name or follow the suggested name for each service listed later in this article.
- Existing Private DNS Zones linked to a single Azure service should not be associated with two different Azure service Private Endpoints. This will cause a deletion of the initial A-record and result in resolution issues when attempting to access that service from each respective Private Endpoint. Create a DNS zone for each Private Endpoint of like services. Don't place records for multiple services in the same DNS zone.

## Azure services DNS zone configuration

Azure creates a canonical name DNS record (CNAME) on the public DNS. The CNAME record redirects the resolution to the private domain name. You can override the resolution with the private IP address of your private endpoints.

Connection URLs for your existing applications don't change. Client DNS requests to a public DNS server resolve to your private endpoints. The process doesn't affect your existing applications.

DNS resolution and access control are independent. The CNAME chain in the public `privatelink.<service>.<region>.<suffix>` zone is deliberately resolvable from anywhere on the internet so that hybrid and gradual-migration scenarios continue to work without breaking existing clients. A successful public DNS lookup confirms only that a resource with that exact name exists in the global Azure namespace. It doesn't confirm that a private endpoint is attached, reveal the private endpoint's IP, or grant any data-plane access. When a resource has **Public network access** set to **Disabled** (or the service firewall denies the caller), the service rejects the connection at the front door regardless of DNS resolution. Resource existence is enumerable; resource access is not.

Important

Azure File Shares must be remounted if connected to the public endpoint.

Caution

- Private networks using a Private DNS Zone for any given resource type (for example, privatelink.blob.core.windows.net/Storage Account) can only resolve DNS Queries to public resources/Public IPs if those public resources don't have any existing Private Endpoint Connections. If this applies, an additional DNS configuration is required on the Private DNS Zone to complete the DNS resolution sequence. Otherwise, the Private DNS Zone will respond to the DNS query with a NXDOMAIN as no matching DNS record would be found in the Private DNS Zone.

> 
> - [Fallback to Internet](../dns/private-dns-fallback) for Private DNS Zone Virtual Network Links can be implemented for proper DNS Resolution for the Public IP of the public resource. This allows DNS queries that reach Private DNS Zones to be forwarded to Azure DNS for public resolution.
> - Alternatively, a manually entered A-record in the Private DNS Zone that contains the Public IP of the public resource would allow for proper DNS resolution. This procedure isn't recommended as the Public IP of the A record in the Private DNS Zone won't be automatically updated if the corresponding public IP address changes for the public resource.
> 

- Private endpoint private DNS zone configurations will only automatically generate if you use the recommended naming scheme in the following tables.

For Azure services, use the recommended zone names as described in the following tables:

## Commercial

### AI + Machine Learning

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Machine Learning workspace (Microsoft.MachineLearningServices/workspaces) | amlworkspace | privatelink.api.azureml.msprivatelink.notebooks.azure.net | api.azureml.msnotebooks.azure.netinstances.azureml.msaznbcontent.netinference.ml.azure.com |
| Azure Machine Learning registry (Microsoft.MachineLearningServices/registries) | amlregistry | privatelink.api.azureml.ms | api.azureml.ms |
| Foundry Tools (Microsoft.CognitiveServices/accounts) | account | privatelink.cognitiveservices.azure.com  privatelink.openai.azure.com  privatelink.services.ai.azure.com | cognitiveservices.azure.com  openai.azure.com  services.ai.azure.com |
| Azure Bot Service (Microsoft.BotService/botServices) | Bot | privatelink.directline.botframework.com | directline.botframework.com |
| Azure Bot Service (Microsoft.BotService/botServices) | Token | privatelink.token.botframework.com | token.botframework.com |

### Analytics

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Synapse Analytics (Microsoft.Synapse/workspaces) | Sql | privatelink.sql.azuresynapse.net | sql.azuresynapse.net |
| Azure Synapse Analytics (Microsoft.Synapse/workspaces) | SqlOnDemand | privatelink.sql.azuresynapse.net | sql.azuresynapse.net |
| Azure Synapse Analytics (Microsoft.Synapse/workspaces) | Dev | privatelink.dev.azuresynapse.net | dev.azuresynapse.net |
| Azure Synapse Studio (Microsoft.Synapse/privateLinkHubs) | Web | privatelink.azuresynapse.net | azuresynapse.net |
| Azure Event Hubs (Microsoft.EventHub/namespaces) | namespace | privatelink.servicebus.windows.net | servicebus.windows.net |
| Azure Service Bus (Microsoft.ServiceBus/namespaces) | namespace | privatelink.servicebus.windows.net | servicebus.windows.net |
| Azure Data Factory (Microsoft.DataFactory/factories) | dataFactory | privatelink.datafactory.azure.net | datafactory.azure.net |
| Azure Data Factory (Microsoft.DataFactory/factories) | portal | privatelink.adf.azure.com | adf.azure.com |
| Azure HDInsight (Microsoft.HDInsight/clusters) | gateway  headnode | privatelink.azurehdinsight.net | azurehdinsight.net |
| Azure Data Explorer (Microsoft.Kusto/Clusters) | cluster | privatelink.{regionName}.kusto.windows.net  privatelink.blob.core.windows.net  privatelink.queue.core.windows.net  privatelink.table.core.windows.net | {regionName}.kusto.windows.net  blob.core.windows.net  queue.core.windows.net  table.core.windows.net |
| Microsoft Power BI (Microsoft.PowerBI/privateLinkServicesForPowerBI) | tenant | privatelink.analysis.windows.net  privatelink.pbidedicated.windows.net  privatelink.prod.powerquery.microsoft.com | analysis.windows.net  pbidedicated.windows.net  prod.powerquery.microsoft.com |
| Azure Databricks (Microsoft.Databricks/workspaces) | databricks\_ui\_api  browser\_authentication | privatelink.azuredatabricks.net | azuredatabricks.net |
| Microsoft Fabric (Microsoft.Fabric/privateLinkServicesForFabric) | workspace | privatelink.fabric.microsoft.com | fabric.microsoft.com |

### Compute

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Batch (Microsoft.Batch/batchAccounts) | batchAccount | privatelink.batch.azure.com | {regionName}.batch.azure.com |
| Azure Batch (Microsoft.Batch/batchAccounts) | nodeManagement | privatelink.batch.azure.com | {regionName}.service.batch.azure.com |
| Azure Virtual Desktop (Microsoft.DesktopVirtualization/workspaces) | global | privatelink-global.wvd.microsoft.com | wvd.microsoft.com |
| Azure Virtual Desktop (Microsoft.DesktopVirtualization/workspaces) | feed | privatelink.wvd.microsoft.com | wvd.microsoft.com |
| Azure Virtual Desktop (Microsoft.DesktopVirtualization/hostpools) | connection | privatelink.wvd.microsoft.com | wvd.microsoft.com |

### Containers

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Kubernetes Service - Kubernetes API (Microsoft.ContainerService/managedClusters) | management | privatelink.{regionName}.azmk8s.io  {subzone}.privatelink.{regionName}.azmk8s.io | {regionName}.azmk8s.io |
| Azure Container Apps (Microsoft.App/ManagedEnvironments) | managedEnvironments | privatelink.{regionName}.azurecontainerapps.io | azurecontainerapps.io |
| Azure Container Registry (Microsoft.ContainerRegistry/registries) | registry | privatelink.azurecr.io  {regionName}.data.privatelink.azurecr.io^1^ | azurecr.io  {regionName}.data.azurecr.io |

### Databases

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure SQL Database (Microsoft.Sql/servers) | sqlServer | privatelink.database.windows.net | database.windows.net |
| Azure SQL Managed Instance (Microsoft.Sql/managedInstances) | managedInstance | privatelink.{dnsPrefix}.database.windows.net | {dnsPrefix}.database.windows.net |
| Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) | Sql | privatelink.documents.azure.com | documents.azure.com |
| Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) | MongoDB | privatelink.mongo.cosmos.azure.com | mongo.cosmos.azure.com |
| Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) | Cassandra | privatelink.cassandra.cosmos.azure.com | cassandra.cosmos.azure.com |
| Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) | Gremlin | privatelink.gremlin.cosmos.azure.com | gremlin.cosmos.azure.com |
| Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) | Table | privatelink.table.cosmos.azure.com | table.cosmos.azure.com |
| Azure Cosmos DB (Microsoft.DocumentDB/databaseAccounts) | Analytical | privatelink.analytics.cosmos.azure.com | analytics.cosmos.azure.com |
| Azure Cosmos DB (Microsoft.DBforPostgreSQL/serverGroupsv2) | coordinator | privatelink.postgres.cosmos.azure.com | postgres.cosmos.azure.com |
| Azure Cosmos DB for MongoDB - vCore (Microsoft.DocumentDB/mongoClusters) | MongoCluster | privatelink.mongocluster.cosmos.azure.com | mongocluster.cosmos.azure.com |
| Azure Database for PostgreSQL - Single server (Microsoft.DBforPostgreSQL/servers) | postgresqlServer | privatelink.postgres.database.azure.com | postgres.database.azure.com |
| Azure Database for PostgreSQL - Flexible server (Microsoft.DBforPostgreSQL/flexibleServers) | postgresqlServer | privatelink.postgres.database.azure.com | postgres.database.azure.com |
| Azure Database for MySQL - Single Server (Microsoft.DBforMySQL/servers) | mysqlServer | privatelink.mysql.database.azure.com | mysql.database.azure.com |
| Azure Database for MySQL - Flexible Server (Microsoft.DBforMySQL/flexibleServers) | mysqlServer | privatelink.mysql.database.azure.com | mysql.database.azure.com |
| Azure Database for MariaDB (Microsoft.DBforMariaDB/servers) | mariadbServer | privatelink.mariadb.database.azure.com | mariadb.database.azure.com |
| Azure Cache for Redis (Microsoft.Cache/Redis) | redisCache | privatelink.redis.cache.windows.net | redis.cache.windows.net |
| Azure Cache for Redis Enterprise (Microsoft.Cache/RedisEnterprise) | redisEnterprise | privatelink.redisenterprise.cache.azure.net | {cachename}.{region}.redisenterprise.cache.azure.net |
| Azure Managed Redis (Microsoft.Cache/RedisEnterprise) | redisEnterprise | privatelink.redis.azure.net | {region}.redis.azure.net |

### Hybrid + multicloud

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Arc (Microsoft.HybridCompute/privateLinkScopes) | hybridcompute | privatelink.his.arc.azure.com  privatelink.guestconfiguration.azure.com  privatelink.dp.kubernetesconfiguration.azure.com | his.arc.azure.com  guestconfiguration.azure.com  dp.kubernetesconfiguration.azure.com |

### Integration

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Service Bus (Microsoft.ServiceBus/namespaces) | namespace | privatelink.servicebus.windows.net | servicebus.windows.net |
| Azure Event Grid (Microsoft.EventGrid/topics) | topic | privatelink.eventgrid.azure.net | eventgrid.azure.net |
| Azure Event Grid (Microsoft.EventGrid/domains) | domain | privatelink.eventgrid.azure.net | eventgrid.azure.net |
| Azure Event Grid (Microsoft.EventGrid/namespaces) | topic | privatelink.eventgrid.azure.net | eventgrid.azure.net |
| Azure Event Grid (Microsoft.EventGrid/namespaces) | topicSpace | privatelink.ts.eventgrid.azure.net | eventgrid.azure.net |
| Azure Event Grid (Microsoft.EventGrid/partnerNamespaces) | partnernamespace | privatelink.eventgrid.azure.net | eventgrid.azure.net |
| Azure API Management (Microsoft.ApiManagement/service) | Gateway | privatelink.azure-api.net | azure-api.net |
| Azure Health Data Services (Microsoft.HealthcareApis/workspaces) | healthcareworkspace | privatelink.azurehealthcareapis.com  privatelink.dicom.azurehealthcareapis.com | workspace.azurehealthcareapis.com  fhir.azurehealthcareapis.com  dicom.azurehealthcareapis.com |

### Internet of Things (IoT)

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure IoT Hub (Microsoft.Devices/IotHubs) | iotHub | privatelink.azure-devices.netprivatelink.servicebus.windows.net^2^ | azure-devices.netservicebus.windows.net |
| Azure IoT Hub Device Provisioning Service (Microsoft.Devices/ProvisioningServices) | iotDps | privatelink.azure-devices-provisioning.net | azure-devices-provisioning.net |
| Device Update for IoT Hubs (Microsoft.DeviceUpdate/accounts) | DeviceUpdate | privatelink.api.adu.microsoft.com | api.adu.microsoft.com |
| Azure IoT Central (Microsoft.IoTCentral/IoTApps) | iotApp | privatelink.azureiotcentral.com  privatelink.azure-devices.net  privatelink.servicebus.windows.net  privatelink.azure-devices-provisioning.net | azureiotcentral.com  privatelink.azure-devices.net  privatelink.servicebus.windows.net  privatelink.azure-devices-provisioning.net |
| Azure Digital Twins (Microsoft.DigitalTwins/digitalTwinsInstances) | API | privatelink.digitaltwins.azure.net | digitaltwins.azure.net |

### Media

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Media Services (Microsoft.Media/mediaservices) | keydelivery  liveevent  streamingendpoint | privatelink.media.azure.net | media.azure.net |
| Azure AI Video Indexer (Microsoft.VideoIndexer/accounts) | account | privatelink.api.videoindexer.ai | api.videoindexer.ai |

### Management and Governance

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Automation (Microsoft.Automation/automationAccounts) | Webhook  DSCAndHybridWorker | privatelink.azure-automation.net | {regionCode}.azure-automation.net |
| Azure Backup (Microsoft.RecoveryServices/vaults) | AzureBackup | privatelink.{regionCode}.backup.windowsazure.com  privatelink.blob.core.windows.net  privatelink.queue.core.windows.net | {regionCode}.backup.windowsazure.com  blob.core.windows.net  queue.core.windows.net |
| Azure Backup (Microsoft.RecoveryServices/vaults) | AzureBackup\_secondary | privatelink.{regionCode}.backup.windowsazure.com  privatelink.blob.core.windows.net  privatelink.queue.core.windows.net | {regionCode}.backup.windowsazure.com  blob.core.windows.net  queue.core.windows.net |
| Azure Site Recovery (Microsoft.RecoveryServices/vaults) | AzureSiteRecovery | privatelink.siterecovery.windowsazure.com | {regionCode}.siterecovery.windowsazure.com |
| Azure Monitor (Microsoft.Insights/privateLinkScopes) | azuremonitor | privatelink.monitor.azure.com privatelink.oms.opinsights.azure.com  privatelink.ods.opinsights.azure.com  privatelink.agentsvc.azure-automation.net  privatelink.blob.core.windows.net | monitor.azure.com oms.opinsights.azure.com ods.opinsights.azure.com agentsvc.azure-automation.net  blob.core.windows.net  services.visualstudio.com  applicationinsights.azure.com |
| Microsoft Purview (Microsoft.Purview/accounts) | account | privatelink.purview.azure.com | purview.azure.com |
| Microsoft Purview (Microsoft.Purview/accounts) | portal | privatelink.purviewstudio.azure.com | purviewstudio.azure.com |
| Microsoft Purview (Microsoft.Purview/accounts) | platform | privatelink.purview-service.microsoft.com | purview-service.microsoft.com |
| Azure Migrate (Microsoft.Migrate/migrateProjects) | Default | privatelink.prod.migration.windowsazure.com | prod.migration.windowsazure.com |
| Azure Migrate (Microsoft.Migrate/assessmentProjects) | Default | privatelink.prod.migration.windowsazure.com | prod.migration.windowsazure.com |
| Azure Resource Manager (Microsoft.Authorization/resourceManagementPrivateLinks) | ResourceManagement | privatelink.azure.com | azure.com |
| Azure Managed Grafana (Microsoft.Dashboard/grafana) | grafana | privatelink.grafana.azure.com | grafana.azure.com |
| Azure Managed Prometheus (Microsoft.Monitor/accounts) | prometheusMetrics | privatelink.{region}.prometheus.monitor.azure.com | {region}.prometheus.monitor.azure.com |

### Security

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Key Vault (Microsoft.KeyVault/vaults) | vault | privatelink.vaultcore.azure.net | vault.azure.net  vaultcore.azure.net |
| Azure Key Vault (Microsoft.KeyVault/managedHSMs) | managedhsm | privatelink.managedhsm.azure.net | managedhsm.azure.net |
| Azure App Configuration (Microsoft.AppConfiguration/configurationStores) | configurationStores | privatelink.azconfig.io | azconfig.io |
| Azure Attestation (Microsoft.Attestation/attestationProviders) | standard | privatelink.attest.azure.net | attest.azure.net |

### Storage

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Storage account (Microsoft.Storage/storageAccounts) | blob  blob\_secondary | privatelink.blob.core.windows.net | blob.core.windows.net |
| Storage account (Microsoft.Storage/storageAccounts) | table  table\_secondary | privatelink.table.core.windows.net | table.core.windows.net |
| Storage account (Microsoft.Storage/storageAccounts) | queue  queue\_secondary | privatelink.queue.core.windows.net | queue.core.windows.net |
| Storage account (Microsoft.Storage/storageAccounts) | file | privatelink.file.core.windows.net | file.core.windows.net |
| Storage account (Microsoft.Storage/storageAccounts) | web  web\_secondary | privatelink.web.core.windows.net | web.core.windows.net |
| Azure Data Lake File System Gen2 (Microsoft.Storage/storageAccounts) | dfs  dfs\_secondary | privatelink.dfs.core.windows.net | dfs.core.windows.net |
| Azure File Sync (Microsoft.StorageSync/storageSyncServices) | afs | privatelink.afs.azure.net | afs.azure.net |
| Azure Managed Disks (Microsoft.Compute/diskAccesses) | disks | privatelink.blob.core.windows.net | blob.core.windows.net |
| Azure Elastic SAN (Microsoft.ElasticSan/elasticSans) | volumegroup | privatelink.blob.core.windows.net | blob.storage.azure.net |
| Azure Files (Microsoft.FileShares/fileShares) | FileShare | privatelink.file.core.windows.net | file.core.windows.net |

### Web

| Private link resource type | Subresource | Private DNS zone name | Public DNS zone forwarders |
| --- | --- | --- | --- |
| Azure Search (Microsoft.Search/searchServices) | searchService | privatelink.search.windows.net | search.windows.net |
| Azure Relay (Microsoft.Relay/namespaces) | namespace | privatelink.servicebus.windows.net | servicebus.windows.net |
| Azure Web Apps / Azure Function Apps (Microsoft.Web/sites) | sites | privatelink.azurewebsites.net  scm.privatelink.azurewebsites.net^3^ | azurewebsites.net  scm.azurewebsites.net |
| SignalR (Microsoft.SignalRService/SignalR) | signalr | privatelink.service.signalr.net | service.signalr.net |
| Azure Static Web Apps (Microsoft.Web/staticSites) | staticSites | privatelink.azurestaticapps.net  privatelink.{partitionId}.azurestaticapps.net | azurestaticapps.net  {partitionId}.azurestaticapps.net |
| Azure Maps (Microsoft.Maps/accounts) | account | privatelink.account.maps.azure.com | account.maps.azure.com |
| Azure Web PubSub service (Microsoft.SignalRService/WebPubSub) | webpubsub | privatelink.webpubsub.azure.com | webpubsub.azure.com |

^1^If you are using Azure Private DNS Zones, do not deploy this as an additional zone. DNS entries will be automatically added to the existing DNS Zone `privatelink.azurecr.io`.

^2^To use with the IoT Hub built-in Event Hubs-compatible endpoint. For more information, see [IoT Hub support for virtual networks with Azure Private Link](../iot-hub/virtual-network-support#built-in-event-hubs-compatible-endpoint).

^3^To use with the Kudu console or Kudu REST API, you must create two DNS records that point to the private endpoint IP address in your Azure DNS private zone `privatelink.azurewebsites.net` or custom DNS server. The first record is for your app. The second record is for source control management (SCM) for your app. If you use private DNS zones in Azure, don't deploy this as an additional zone.

Note

In the above text, **`{regionCode}`** refers to the region code (for example, **eus** for East US and **ne** for North Europe). Refer to the following lists for regions codes:

- [All public clouds](https://download.microsoft.com/download/1/2/6/126a410b-0e06-45ed-b2df-84f353034fa1/AzureRegionCodesList.docx)
- [Geo Code list in XML](/en-us/azure/backup/scripts/geo-code-list)

**`{regionName}`** refers to the full region name (for example, **eastus** for East US and **northeurope** for North Europe). To retrieve a current list of Azure regions and their names and display names, use **`az account list-locations -o table`**.