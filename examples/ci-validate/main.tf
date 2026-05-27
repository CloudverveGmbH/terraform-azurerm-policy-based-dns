terraform {
  required_version = ">= 1.9"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

provider "azurerm" {
  alias = "connectivity"
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

module "private_dns_policy" {
  source = "../.."

  location                    = "germanywestcentral"
  dns_resource_group_name     = "rg-ci-validate"
  policy_assignment_scope_ids = {}
  enabled_categories          = null
  enabled_services            = null
  service_overrides           = {}

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
}
