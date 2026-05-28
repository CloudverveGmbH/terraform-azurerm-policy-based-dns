# AI Agent Context – private_dns_policy module

This file gives an AI agent the context needed to work effectively in this Terraform module.

---

## What this module is

A **reusable Terraform module** that implements policy-driven private DNS registration for Azure Private Endpoints, following the Microsoft CAF pattern:
[Private Link and DNS integration at scale](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale).

---

## Key concepts

**The problem being solved:** When a Private Endpoint is created, a DNS A record must be registered so that workloads resolve the private IP. This module automates that via `DeployIfNotExists` (DINE) Azure Policy — no manual DNS management required.

**How the DINE policy works:**
1. A pinned custom policy definition snapshot from the ALZ repo is loaded from the module package via `jsondecode`
2. The policy watches for Private Endpoints matching a given `resourceType` and `groupId`
3. On match, it deploys a `privateDnsZoneGroup` onto the endpoint
4. Azure writes/cleans up the A record automatically in the linked Private DNS Zone

---

## File map

| File | Purpose |
|---|---|
| `catalog.tf` | Service catalog (group_id, resource_type, zone_name, category) + selection logic → `effective_subresource_zone_map` |
| `network.tf` | DNS zone deduplication: create (`azurerm_private_dns_zone`) or look up (`data.azurerm_private_dns_zone`) per zone_name |
| `policies.tf` | Vendored policy JSON import, Policy Definition, Assignments (RG/Sub/MG), RBAC |
| `variables.tf` | All input variables |
| `outputs.tf` | Key outputs: `zone_ids`, `effective_subresource_zone_map`, `assignment_principal_ids`, scope outputs |
| `main.tf` | Provider alias declarations (`azurerm`, `azurerm.connectivity`) |
| `category_selection.tftest.hcl` | Terraform native test suite for category/service selection (7 runs) |
| `assignment_logic.tftest.hcl` | Terraform native test suite for assignment scope routing (7 runs) |

---

## Selection logic

The catalog is static. What gets activated is controlled exclusively by:

| Variable | Type | Effect |
|---|---|---|
| `enabled_categories` | `map(bool)` | Activate all services in a category; bool = `create_zone` |
| `enabled_services` | `map(bool)` | Override individual service keys; bool = `create_zone` |

Resolution order:
1. Expand `enabled_categories` to service keys
2. Merge `enabled_services` on top (overrides win)
3. Result → `effective_subresource_zone_map`

**Critical:** `true` = Terraform creates the DNS zone. `false` = zone already exists, use data source (or `existing_zone_id`).

### Common scenario: cross-category composition

```hcl
enabled_categories = { Hybrid = true }   # arc_his, arc_guestconfig, arc_k8s → create zones
enabled_services   = { blob = false }    # also watch blob endpoints → use existing zone
service_overrides = {
  blob = {
    existing_zone_id = "/subscriptions/.../resourceGroups/rg-connectivity/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  }
}
```

This produces assignments on the same RG scope for 4 services. The `rg_assignment_scopes` local deduplicates via `toset(distinct([...]))` before creating `Network Contributor` role assignments.

**Note:** When a zone is referenced with `create_zone = false` and no `existing_zone_id`, the module performs a data source lookup in `dns_resource_group_name`. To reference a zone in a different resource group, always supply `existing_zone_id` via `service_overrides`.

---

## Zone deduplication (network.tf)

Multiple service keys may share the same `zone_name` (e.g. `blob`, `managed_disks`, `elastic_san`, `azuremonitor_blob` all use `privatelink.blob.core.windows.net`).

Deduplication rule per `zone_name`:
- If **any** active service has `create_zone = true` → `azurerm_private_dns_zone` resource
- If **all** active services have `create_zone = false` → `data.azurerm_private_dns_zone` lookup
- If `existing_zone_id` is set via `service_overrides` → use that ID directly, skip both

The final `zone_ids` map is keyed by `zone_name`, not by service key.

---

## Policy assignment deduplication (policies.tf)

Assignments are built from a generic scope map:
- `policy_assignment_scope_ids` (map of friendly name -> mixed RG/Sub/MG scope ID)

Policy definition scope is configured independently:
- `policy_definition_at_management_group` (optional; MG short name or full MG resource ID)

With many services and one scope, many assignments target the same resource group/subscription/management group.

`rg_assignment_scopes`, `subscription_assignment_scopes`, `management_group_assignment_scopes` are built with `toset(distinct([...]))` to ensure the `Network Contributor` role is only assigned once per unique scope — regardless of how many service assignments target that scope.

The module also blocks assignment overlap where a subscription-level assignment and a resource-group assignment in the same subscription are configured at the same time.

---

## Managed identity model

One **User-Assigned Managed Identity** is shared across all policy assignments:

- Created in `dns_resource_group_name` via `azurerm_user_assigned_identity.policy_assignment`
- Name controlled by `assignment_identity_name` (default: `id-clv-private-dns-policy`)
- RBAC granted:
  - `Private DNS Zone Contributor` on each active DNS zone
  - `Network Contributor` on each unique assignment scope (RG/Sub/MG)

---

## Key constraints

- **Do not add `private_dns_zone_group` to private endpoint resources elsewhere** — Terraform and the DINE policy will conflict over ownership.
- **Policy evaluation delay:** Azure Policy triggers 3–10 minutes after endpoint creation. This is normal.
- **`existing_zone_id` conflict check:** If two service keys with the same `zone_name` supply different `existing_zone_id` values, apply is blocked via resource `precondition`.
- **ALZ policy source is pinned** as a vendored JSON file (`policy_definitions/Deploy-Private-DNS-Generic.2026-04-29.json`) with SHA256 validation.

---

## Test suite

> **Agent instruction:** After every code change to this module, always run `terraform test` automatically and report the result. Do not consider a task complete until the test suite passes (or explicitly discuss any failing tests with the user).

Run from the module directory:

```bash
terraform test
```

Current test runs (`selection_logic.tftest.hcl`):

| Run | What it validates |
|---|---|
| `storage_category_creates_zones` | Storage category activates blob/file/etc. with create_zone=true |
| `web_category_with_service_override` | Category base + per-service override merges correctly |
| `shared_zone_deduplicated` | blob + azuremonitor_blob keep only 1 zone_id entry |
| `empty_selection_results_in_empty_map` | null inputs → empty map, no assignments |
| `regional_aks_key_override` | aks_weu explicit override; aks + aks_gwc from category remain false |
| `existing_zone_id_override_is_used` | existing_zone_id bypasses create/lookup, ID used directly |
| `hybrid_category_with_blob_as_existing_zone` | Hybrid(3 services) + blob=false+existing_zone_id → 4 assignments, 1 deduplicated RG scope |
| `rg_scopes_deduplicated_with_multiple_services` | 2 RG scopes with many services → exactly 2 unique scopes |

---

## Naming conventions

Pattern: `<type>-<org>-<workload>[-<qualifier>]-<region-short>`

- Org: `clv` (cloudverve)
- Region: `gwc` (Germany West Central)
- Policy definition name: `clv-deploy-private-dns-generic`
- Managed identity: `id-clv-private-dns-policy`
