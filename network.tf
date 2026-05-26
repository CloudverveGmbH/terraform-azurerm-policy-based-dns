#
# Zone deduplication
#
# Multiple service keys may reference the same zone_name
# (e.g. "blob", "azuremonitor_blob", and "backup_azurebackup" all use
# privatelink.blob.core.windows.net).
#
# Resolution rule: if ANY active service for a given zone_name has
# create_zone = true, that zone is created; otherwise it is looked up.
#
# zone_ids is keyed by zone_name, not by service key.
#
locals {
  zone_existing_id_values_by_zone = {
    for zone_name in toset([for _, cfg in local.effective_subresource_zone_map : cfg.zone_name]) :
    zone_name => distinct(compact([
      for _, cfg in local.effective_subresource_zone_map : try(cfg.existing_zone_id, null)
      if cfg.zone_name == zone_name
    ]))
  }

  conflicting_existing_zone_ids = {
    for zone_name, ids in local.zone_existing_id_values_by_zone : zone_name => ids
    if length(ids) > 1
  }

  forced_existing_zone_ids = {
    for zone_name, ids in local.zone_existing_id_values_by_zone : zone_name => ids[0]
    if length(ids) == 1
  }

  # Build a map: zone_name -> create_zone (true wins over false)
  unique_zone_create_flags = {
    for zone_name in toset([for _, cfg in local.effective_subresource_zone_map : cfg.zone_name]) :
    zone_name => anytrue([
      for _, cfg in local.effective_subresource_zone_map : cfg.create_zone
      if cfg.zone_name == zone_name
    ])
    if !contains(keys(local.forced_existing_zone_ids), zone_name)
  }

  unique_zones_to_create = {
    for zone_name, create in local.unique_zone_create_flags : zone_name => zone_name
    if create
  }

  unique_zones_existing = {
    for zone_name, create in local.unique_zone_create_flags : zone_name => zone_name
    if !create
  }
}

resource "azurerm_private_dns_zone" "managed" {
  provider = azurerm.connectivity
  for_each = local.unique_zones_to_create

  name                = each.key
  resource_group_name = var.dns_resource_group_name

  lifecycle {
    precondition {
      condition     = length(local.conflicting_existing_zone_ids) == 0
      error_message = "Conflicting existing_zone_id values found for one or more zone_name entries: ${jsonencode(local.conflicting_existing_zone_ids)}"
    }
  }
}

data "azurerm_private_dns_zone" "existing" {
  provider = azurerm.connectivity
  for_each = local.unique_zones_existing

  name                = each.key
  resource_group_name = var.dns_resource_group_name
}

locals {
  # Keyed by zone_name — shared across all services that use the same zone
  zone_ids = merge(
    local.forced_existing_zone_ids,
    { for zone_name, zone in azurerm_private_dns_zone.managed : zone_name => zone.id },
    { for zone_name, zone in data.azurerm_private_dns_zone.existing : zone_name => zone.id }
  )
}

locals {
  # Cross-product: one link per (zone_name, vnet_key) — only for zones Terraform creates
  vnet_link_pairs = {
    for pair in flatten([
      for zone_name in keys(local.unique_zones_to_create) : [
        for vnet_key, vnet_id in var.vnet_links : {
          key       = "${replace(zone_name, ".", "-")}-${vnet_key}"
          zone_name = zone_name
          vnet_id   = vnet_id
        }
      ]
    ]) : pair.key => pair
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  provider = azurerm.connectivity
  for_each = local.vnet_link_pairs

  name                  = each.key
  resource_group_name   = var.dns_resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = each.value.vnet_id

  depends_on = [azurerm_private_dns_zone.managed]
}

