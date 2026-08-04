terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "~> 5.0"
      configuration_aliases = [azurerm.connectivity]
    }
    http = {
      source = "hashicorp/http"
    }
  }
}
