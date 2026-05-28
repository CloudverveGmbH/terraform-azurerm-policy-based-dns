# Changelog

All notable changes to this module are documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.0.6] u2014 2026-05-28

### Changed
- Github release flow is now done manually. Changed actions for that ([#8](https://github.com/CloudverveGmbH/terraform-azurerm-policy-based-dns/pull/8))


## [0.0.5]
### Changed
- Changed github workflow to be PR based ([#4](https://github.com/CloudverveGmbH/terraform-azurerm-policy-based-dns/pull/4))

### Fixed
- `existing_zone_id` now properly gets resource types and group id for assignments ([#4](https://github.com/CloudverveGmbH/terraform-azurerm-policy-based-dns/pull/4))


## [0.0.3] - 2026-05-28
### Fixed
- ´existing_zone_id` is now enough to manage a service in a different private dns zone, if the key matches one in the catalog

## [0.0.2] - 2026-05-27

### Changed
- ALZ Policy is now included in this repository.
- Version check of policy template is done via github actions
- CI Workflow now uses wrapper module to execute `terraform validate`

## [0.0.1] — 2026-05-26

Policy-driven private DNS registration for Azure Private Endpoints, following the
[Microsoft CAF: Private Link and DNS integration at scale](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/private-link-and-dns-integration-at-scale) pattern.

### Features

- Most Azure service keys across 10 categories (Storage, Databases, Analytics, Compute, Security, Hybrid, IoT, Media, Management, Web) based on [Azure Private Endpoint private DNS zone values](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)
- `DeployIfNotExists` policy assignments at Resource Group, Subscription, or Management Group scope
- Zone deduplication: shared `zone_name` across service keys is created/looked-up exactly once
- Single User-Assigned Managed Identity shared across all assignments
- ALZ policy JSON vendored locally with SHA256 integrity check
- Optional latest-version drift detection against `Azure/Enterprise-Scale` main branch
- VNet links for managed DNS zones
- Terraform native test suite (14 runs across 2 test files)

### Policy

- Vendored ALZ policy tag: `2026-04-29`
- SHA256: `a2e3805c1129b5d540f38fbfe9f3c0608926c64526023a22fdaac7b81b22287a`

### Requirements

- Terraform `>= 1.9`
- AzureRM provider `>= 3.116`
- Two `azurerm` provider aliases: default (workload sub) + `azurerm.connectivity`
