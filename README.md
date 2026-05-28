# private_dns_policy

A reusable Terraform module that automates private DNS registration for Azure Private Endpoints using a `DeployIfNotExists` policy (DINE pattern, following Microsoft CAF).

## Overview

**Problem:** Every Private Endpoint requires a DNS A record so workloads can resolve the private IP. Managing this manually does not scale.

**Solution:** The module imports a generic ALZ policy definition and automatically assigns it to the configured scopes. When a Private Endpoint is created, the policy deploys a `privateDnsZoneGroup` onto it — Azure writes and maintains the A record automatically.

**Configuration in three steps:**

1. **Activate categories/services** — `enabled_categories` and/or `enabled_services` control which services are watched. The `bool` value means `create_zone`: `true` = Terraform creates the DNS zone, `false` = zone already exists and is read via data source.
2. **Set scopes** — `policy_definition_at_management_group` (optional, definition scope only) and `policy_assignment_scope_ids` (friendly-name map for RG/Sub/MG assignments).
3. **Override optionally** — `service_overrides` allows per-service-key customisation of `group_id`, `resource_type`, `zone_name`, or `existing_zone_id` (for zones in different resource groups).

The module handles deduplication of DNS zones (multiple services, one zone) and RBAC assignments (multiple assignments, one scope) internally. A single User-Assigned Managed Identity is shared across all policy assignments.

---

## Reference

This module implements policy-based private DNS integration for Private Endpoints as **one module with multiple files**:

- `catalog.tf`: DNS lookup table + category/service mapping logic.
- `network.tf`: Resolve or create DNS zones (depending on `create_zone`).
- `policies.tf`: vendored ALZ policy JSON import via `jsondecode`, policy definition, assignments and RBAC.
- `main.tf`: Provider declarations for the module.

## Managed Identity Model

All policy assignments use **one** shared User-Assigned Managed Identity.

- The identity is created in the connectivity RG (`dns_resource_group_name`).
- The name is configurable via `assignment_identity_name`.
- RBAC (`Private DNS Zone Contributor`, `Network Contributor`) is granted to this single identity.

## Core Concept

The lookup table is purely functional (`group_id`, `resource_type`, `zone_name`, `category`).
**Whether DNS zones are created** is driven exclusively by the selection variables:

- `enabled_categories` (`map(bool)`)
- `enabled_services` (`map(bool)`) — overrides categories

`bool` means: `create_zone`.

## Selection Behaviour

Resolution order:

1. Expand `enabled_categories` to service keys
2. Merge explicit services from `enabled_services` on top (overrides win)
3. Result is resolved to `effective_subresource_zone_map`

If **both variables are `null`/empty**, nothing is active (explicit opt-in required).

### Examples

```hcl
# 1) Storage active, create DNS zones
enabled_categories = {
  Storage = true
}
```

Result: all Storage entries active, each with `create_zone = true`.

```hcl
# 2) Web active, but use existing zones
enabled_categories = {
  Web = false
}
```

Result: `webapp`, `webapp_scm`, `staticwebapp` active with `create_zone = false`.

```hcl
# 3) Category + explicit override
enabled_categories = {
  Web = false
}

enabled_services = {
  staticwebapp = true
}
```

Result:

- `webapp` / `webapp_scm` => `create_zone = false`
- `staticwebapp` => `create_zone = true`

## Available Categories

| Category | MS docs section | Includes |
|---|---|---|
| `Storage` | Storage | blob, file, queue, table, dfs, web, afs, managed_disks, elastic_san, azure_files |
| `Security` | Security | vault, managedhsm, appconfiguration, attestation |
| `Analytics` | AI+ML, Analytics | amlworkspace, synapse, eventhubs, datafactory, powerbi, databricks, fabric, bot, dataexplorer |
| `Compute` | Compute, Containers | batch, avd, aks, containerapps, acr, containerinstance |
| `Databases` | Databases | sql_server, cosmosdb_*, postgres, mysql, mariadb, redis, redis_enterprise |
| `Hybrid` | Hybrid + multicloud | arc_his, arc_guestconfig, arc_k8s |
| `IoT` | IoT | iothub, iot_dps, device_update, iot_central, digital_twins |
| `Media` | Media | media_keydelivery, media_liveevent, media_streamingendpoint, video_indexer |
| `Management` | Management and Governance, Integration | azuremonitor, backup, siterecovery, grafana, purview, eventgrid, apim, healthcare, ... |
| `Web` | Web | webapp, webapp_scm, staticwebapp, signalr, webpubsub, searchservice, relay, maps |

## Shared DNS Zones (Deduplication)

Multiple services can reference the same `zone_name`. Example: `blob`, `managed_disks`, `elastic_san` and `azuremonitor_blob` all use `privatelink.blob.core.windows.net`.

**Behaviour:**
- DNS zones are deduplicated **per zone** (not per service).
- `zone_ids` in the output is a `map(string)` keyed by `zone_name`.
- If **at least one** active service for a zone has `create_zone = true`, the zone is created — all other services referencing the same zone use the same zone ID.
- If **all** services for a zone have `create_zone = false`, the zone is assumed to already exist (data source lookup).

**Example:**

```hcl
enabled_categories = { Storage = true }           # blob → create_zone = true
enabled_services   = { azuremonitor_blob = false } # also blob zone, but no create needed
```

Result: `privatelink.blob.core.windows.net` is created once; both services use the same zone ID.

## Policy Scopes

Policy definition scope and assignment scopes are deliberately decoupled (separation of concerns):

- `policy_definition_at_management_group` (`string|null`): optional MG scope for the policy definition. Accepts a full MG resource ID or a short name.
- `policy_assignment_scope_ids` (`map(string)`): generic assignment scopes keyed by friendly name. Supports RG, subscription, and MG IDs; scope type is detected automatically from the ID format.

Important:

- Defining the policy on Root MG and assigning on child MGs is supported directly.
- MG assignment scopes require `policy_definition_at_management_group` to be set — a subscription-scoped definition is not visible from a management group assignment.
- Overlapping scopes are blocked: if the same subscription appears as both a subscription-level assignment and a resource-group-level assignment, the plan fails.

Example (RG + explicit subscriptions):

```hcl
policy_assignment_scope_ids = {
  rg_app_prod_weu = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod-weu"
  sub_one         = "/subscriptions/11111111-1111-1111-1111-111111111111"
  sub_two         = "/subscriptions/22222222-2222-2222-2222-222222222222"
}

policy_definition_at_management_group = null
```

Example (definition on Root MG, assignments on child MGs):

```hcl
policy_definition_at_management_group = "mg-root"

policy_assignment_scope_ids = {
  mg_platform_prod     = "/providers/Microsoft.Management/managementGroups/mg-platform-prod"
  mg_connectivity_prod = "/providers/Microsoft.Management/managementGroups/mg-connectivity-prod"
  rg_app_prod_weu      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod-weu"
}
```

Example (definition on MG, but only RG and subscription assignments):

```hcl
policy_definition_at_management_group = "mg-platform-prod"

policy_assignment_scope_ids = {
  sub_one         = "/subscriptions/11111111-1111-1111-1111-111111111111"
  rg_app_prod_weu = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod-weu"
}
```

Not allowed (blocked by precondition):

```hcl
# MG assignment scope without policy_definition_at_management_group
policy_assignment_scope_ids = {
  mg_platform_prod = "/providers/Microsoft.Management/managementGroups/mg-platform-prod"
}
# policy_definition_at_management_group = null  ← missing

# Overlapping subscription + RG from the same subscription
policy_assignment_scope_ids = {
  sub_one         = "/subscriptions/11111111-1111-1111-1111-111111111111"
  rg_app_prod_weu = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-app-prod-weu"
}
```

## Remediation

`DeployIfNotExists` acts primarily on new or re-evaluated resources. Existing Private Endpoints are not automatically remediated immediately; Azure Policy Remediation Tasks or a later compliance re-evaluation are required for those.

## ALZ Policy Source (pinned)

This module uses the ALZ [`Deploy-Private-DNS-Generic`](https://github.com/Azure/Enterprise-Scale/blob/main/src/resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic.json) policy and bundles a pinned JSON snapshot with the module package.

## Notes

- Regional service keys are available for services that require a region in the zone name (`aks_gwc`, `aks_weu`, `acr_data_gwc`, `acr_data_weu`, `containerinstance_gwc`, `containerinstance_weu`).
- For region-code-based zones (e.g. Azure Backup), `region_code` is used.
- `service_overrides` allows customising `group_id`, `resource_type`, `zone_name` and `existing_zone_id` per service key.

### Using an existing zone from a different resource group

If a Private DNS Zone already exists (e.g. from an existing AKS setup in another RG), it can be referenced directly by ID per service key:

```hcl
service_overrides = {
  aks_weu = {
    existing_zone_id = "/subscriptions/<sub>/resourceGroups/<existing-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
  }
}
```

Behaviour:
- When `existing_zone_id` is set, the zone is **not** created and **not** looked up via data source in `dns_resource_group_name`.
- The provided zone ID is used directly for policy assignments and RBAC.
- If multiple active service keys share the same `zone_name`, they must all reference the same `existing_zone_id` (otherwise a module precondition will fail).

> **Note:** Setting `existing_zone_id` in `service_overrides` is sufficient to activate the service key — no additional entry in `enabled_services` is required. The zone is used directly as-is (`create_zone = false`).
>
> If you want to activate a service key *without* `existing_zone_id` (e.g. to let the module look up the zone via data source), you still need to add the key to `enabled_services`.
>
> For fully custom keys not in the built-in catalog, `group_id` and `resource_type` must also be set in `service_overrides` — either alongside `existing_zone_id` or with an explicit `zone_name`.

## AI Disclosure

- This module (Terraform code, tests, and documentation) was built with AI assistance (GitHub Copilot / Claude).
- All technical content should be reviewed and validated by a human before use in production or critical environments.
- This module is provided as-is, without warranty or guarantee of completeness, accuracy, or fitness for a specific purpose.

---

---

# private_dns_policy module (Deutsch)

# Zusammenfassung

Dieses Modul automatisiert die DNS-Registrierung für Azure Private Endpoints mittels einer `DeployIfNotExists`-Policy (DINE-Pattern nach Microsoft CAF).

**Problem:** Jeder Private Endpoint braucht einen DNS-A-Record, damit Workloads die private IP auflösen können. Das manuell zu pflegen skaliert nicht.

**Lösung:** Das Modul importiert eine generische ALZ-Policy-Definition und weist sie automatisch auf den konfigurierten Scopes zu. Sobald ein Private Endpoint entsteht, deployt die Policy eine `privateDnsZoneGroup` auf den Endpoint — Azure schreibt und pflegt den A-Record selbst.

**Konfiguration in drei Schritten:**

1. **Kategorien/Services aktivieren** — `enabled_categories` und/oder `enabled_services` steuern, welche Dienste überwacht werden. Der `bool`-Wert bedeutet `create_zone`: `true` = Terraform erstellt die DNS-Zone, `false` = Zone existiert bereits und wird per Data Source gelesen.
2. **Scopes festlegen** — `policy_definition_at_management_group` (optional, nur für Definition-Scope) und `policy_assignment_scope_ids` (friendly-name Map für RG/Sub/MG-Assignments).
3. **Optional überschreiben** — `service_overrides` erlaubt pro Service-Key Anpassungen von `group_id`, `resource_type`, `zone_name` oder `existing_zone_id` (für Zonen in fremden Resource Groups).

Das Modul verwaltet intern die Deduplizierung von DNS-Zonen (mehrere Services, eine Zone) und von RBAC-Zuweisungen (mehrere Assignments, ein Scope). Eine einzige User-Assigned Managed Identity wird für alle Policy Assignments verwendet.

---

## Referenz

Dieses Modul kapselt die policy-basierte Private-DNS-Integration für Private Endpoints als **ein Modul mit mehreren Dateien**:

- `catalog.tf`: DNS-Lookup-Tabelle + Kategorie/Service-Mappinglogik.
- `network.tf`: DNS-Zonen auflösen oder erstellen (je nach `create_zone`).
- `policies.tf`: vendored ALZ Policy JSON Import per `jsondecode`, Policy Definition, Assignments und RBAC.
- `main.tf`: Provider-Definitionen für das Modul.

## Managed Identity Modell

Alle Policy Assignments verwenden **eine** gemeinsame User-Assigned Managed Identity.

- Die Identity wird im Connectivity-RG (`dns_resource_group_name`) angelegt.
- Name ist über `assignment_identity_name` steuerbar.
- RBAC (`Private DNS Zone Contributor`, `Network Contributor`) wird auf diese eine Identity vergeben.

## Kernidee

Die Lookup-Tabelle ist rein fachlich (`group_id`, `resource_type`, `zone_name`, `category`).
**Ob DNS-Zonen erstellt werden**, kommt ausschließlich aus den Selektionsvariablen:

- `enabled_categories` (`map(bool)`)
- `enabled_services` (`map(bool)`) – überschreibt Kategorien

`bool` bedeutet: `create_zone`.

## Selektionsverhalten (erwartet)

Auswertungsreihenfolge:

1. Kategorien aus `enabled_categories` expandieren auf Service-Keys
2. Explizite Services aus `enabled_services` darüber mergen (Override)
3. Ergebnis wird zu `effective_subresource_zone_map` aufgelöst

Wenn **beide Variablen `null`/leer** sind, ist nichts aktiv (explizites Opt-in).

### Beispiele

```hcl
# 1) Storage aktiv und DNS-Zonen erstellen
enabled_categories = {
  Storage = true
}
```

Ergebnis: alle Storage-Einträge aktiv, jeweils `create_zone = true`.

```hcl
# 2) Web aktiv, aber bestehende Zonen nutzen
enabled_categories = {
  Web = false
}
```

Ergebnis: `webapp`, `webapp_scm`, `staticwebapp` aktiv mit `create_zone = false`.

```hcl
# 3) Kategorie + expliziter Override
enabled_categories = {
  Web = false
}

enabled_services = {
  staticwebapp = true
}
```

Ergebnis:

- `webapp` / `webapp_scm` => `create_zone = false`
- `staticwebapp` => `create_zone = true`

## Verfügbare Kategorien

| Kategorie | MS-Doc Abschnitt | Enthält |
|---|---|---|
| `Storage` | Storage | blob, file, queue, table, dfs, web, afs, managed_disks, elastic_san, azure_files |
| `Security` | Security | vault, managedhsm, appconfiguration, attestation |
| `Analytics` | AI+ML, Analytics | amlworkspace, synapse, eventhubs, datafactory, powerbi, databricks, fabric, bot, dataexplorer |
| `Compute` | Compute, Containers | batch, avd, aks, containerapps, acr, containerinstance |
| `Databases` | Databases | sql_server, cosmosdb_*, postgres, mysql, mariadb, redis, redis_enterprise |
| `Hybrid` | Hybrid + multicloud | arc_his, arc_guestconfig, arc_k8s |
| `IoT` | IoT | iothub, iot_dps, device_update, iot_central, digital_twins |
| `Media` | Media | media_keydelivery, media_liveevent, media_streamingendpoint, video_indexer |
| `Management` | Management and Governance, Integration | azuremonitor, backup, siterecovery, grafana, purview, eventgrid, apim, healthcare, ... |
| `Web` | Web | webapp, webapp_scm, staticwebapp, signalr, webpubsub, searchservice, relay, maps |

## Geteilte DNS-Zonen (Deduplication)

Mehrere Services können dieselbe `zone_name` referenzieren. Beispiel: `blob`, `managed_disks`, `elastic_san` und `azuremonitor_blob` nutzen alle `privatelink.blob.core.windows.net`.

**Verhalten:**
- DNS-Zonen werden **pro Zone** (nicht pro Service) dedupliziert.
- `zone_ids` im Output ist ein `map(string)` mit `zone_name` als Key.
- Wenn **mindestens einer** der aktivierten Services für eine Zone `create_zone = true` hat, wird die Zone angelegt — alle anderen Services mit derselben Zone profitieren davon.
- Wenn **alle** Services eine Zone mit `create_zone = false` referenzieren, wird die Zone als bestehend angenommen (data source lookup).

**Beispiel:**

```hcl
enabled_categories = { Storage = true }      # blob → create_zone = true
enabled_services   = { azuremonitor_blob = false }  # auch blob-Zone, aber create nicht nötig
```

Ergebnis: `privatelink.blob.core.windows.net` wird einmal erstellt, beide Services nutzen dieselbe Zone-ID.

## Policy Scopes verwenden

Definition und Assignments sind bewusst entkoppelt (Separation of Concerns):

- `policy_definition_at_management_group` (`string|null`): optionaler MG-Scope für die Policy Definition.
- `policy_assignment_scope_ids` (`map(string)`): generische Assignment-Scopes mit Friendly Name als Key. Unterstützt RG-, Subscription- und MG-IDs; der Scope-Typ wird automatisch erkannt.

Wichtig:

- Eine Definition auf Root-MG und Assignments auf Child-MGs ist direkt möglich.
- MG-Assignment-Scopes setzen voraus, dass `policy_definition_at_management_group` gesetzt ist — eine Subscription-scoped Definition ist von einem MG-Assignment aus nicht sichtbar.
- Das Modul blockiert über eine Precondition überlappende Scopes, wenn für dieselbe Subscription sowohl ein Subscription-Assignment als auch ein RG-Assignment konfiguriert wird.

Beispiel (RG + explizite Subscriptions):

```hcl
policy_assignment_scope_ids = {
  rg_app_prod_weu = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod-weu"
  sub_one         = "/subscriptions/11111111-1111-1111-1111-111111111111"
  sub_two         = "/subscriptions/22222222-2222-2222-2222-222222222222"
}

policy_definition_at_management_group = null
```

Beispiel (Definition auf Root-MG, Assignments auf Child-MGs):

```hcl
policy_definition_at_management_group = "mg-root"

policy_assignment_scope_ids = {
  mg_platform_prod     = "/providers/Microsoft.Management/managementGroups/mg-platform-prod"
  mg_connectivity_prod = "/providers/Microsoft.Management/managementGroups/mg-connectivity-prod"
  rg_app_prod_weu      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod-weu"
}
```

Beispiel (Definition auf MG, aber nur RG- und Subscription-Assignments):

```hcl
policy_definition_at_management_group = "mg-platform-prod"

policy_assignment_scope_ids = {
  sub_one         = "/subscriptions/11111111-1111-1111-1111-111111111111"
  rg_app_prod_weu = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-app-prod-weu"
}
```

Nicht erlaubt (wird geblockt):

```hcl
# MG-Assignment-Scope ohne policy_definition_at_management_group
policy_assignment_scope_ids = {
  mg_platform_prod = "/providers/Microsoft.Management/managementGroups/mg-platform-prod"
}
# policy_definition_at_management_group = null  ← fehlt

# Überlappende Subscription + RG derselben Subscription
policy_assignment_scope_ids = {
  sub_one         = "/subscriptions/11111111-1111-1111-1111-111111111111"
  rg_app_prod_weu = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-app-prod-weu"
}
```

## Remediation-Hinweis

`DeployIfNotExists` wirkt primär auf neue bzw. neu evaluierte Ressourcen. Bereits bestehende Private Endpoints werden nicht automatisch sofort remediated; dafür sind Azure Policy Remediation Tasks bzw. eine spätere Compliance-Neuauswertung erforderlich.

## ALZ Policy Quelle (gepinned)

Dieses Modul nutzt die ALZ-Policy [`Deploy-Private-DNS-Generic`](https://github.com/Azure/Enterprise-Scale/blob/main/src/resources/Microsoft.Authorization/policyDefinitions/Deploy-Private-DNS-Generic.json) und bündelt einen gepinnten JSON-Snapshot im Modulpaket.

## Hinweise

- Für regionale Services stehen explizite Keys zur Verfügung (`aks_gwc`, `aks_weu`, `acr_data_gwc`, `acr_data_weu`, `containerinstance_gwc`, `containerinstance_weu`).
- Für region-code-basierte Zonen (z. B. Azure Backup) wird `region_code` verwendet.
- Mit `service_overrides` können `group_id`, `resource_type`, `zone_name` und `existing_zone_id` pro Service-Key angepasst werden.

### Bestehende Zone in anderer Resource Group nutzen

Wenn eine Private DNS Zone bereits existiert (z. B. aus einem bestehenden AKS-Setup in anderer RG), kann sie pro Service-Key direkt per ID referenziert werden:

```hcl
service_overrides = {
  aks_weu = {
    existing_zone_id = "/subscriptions/<sub>/resourceGroups/<existing-rg>/providers/Microsoft.Network/privateDnsZones/privatelink.westeurope.azmk8s.io"
  }
}
```

Verhalten:
- Bei gesetztem `existing_zone_id` wird die Zone **nicht** erstellt und **nicht** per Data Source in `dns_resource_group_name` gesucht.
- Die angegebene Zone-ID wird direkt für die Policy-Assignments/RBAC verwendet.
- Wenn mehrere aktivierte Service-Keys auf dieselbe `zone_name` zeigen, müssen sie auf dieselbe `existing_zone_id` zeigen (sonst schlägt ein Modul-Check fehl).

> **Hinweis:** Das Setzen von `existing_zone_id` in `service_overrides` reicht aus, um den Service-Key zu aktivieren — kein zusätzlicher Eintrag in `enabled_services` erforderlich. Die Zone wird direkt verwendet (`create_zone = false`).
>
> Wenn ein Service-Key *ohne* `existing_zone_id` aktiviert werden soll (z. B. damit das Modul die Zone per Data Source nachschlägt), muss der Key weiterhin in `enabled_services` eingetragen werden.
>
> Für vollständig eigene Keys, die nicht im eingebauten Catalog stehen, müssen `group_id` und `resource_type` ebenfalls in `service_overrides` gesetzt sein — entweder zusammen mit `existing_zone_id` oder mit einem expliziten `zone_name`.

## AI-Hinweis

- Dieses Modul (Terraform-Code, Tests und Dokumentation) wurde mit KI-Unterstützung erstellt (GitHub Copilot / Claude).
- Alle technischen Inhalte sollten vor produktivem oder kritischem Einsatz von einer Person geprüft und bestätigt werden.
- Dieses Modul wird ohne Gewähr bereitgestellt; Vollständigkeit, Richtigkeit und Eignung für einen bestimmten Zweck sind nicht garantiert.
