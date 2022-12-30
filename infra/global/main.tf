terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.33.0"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {}
}

variable "prefix" {
  default = "unchained"
  type = string
}

resource "azurerm_resource_group" "rg" {
  name = "website-${var.prefix}"
  location = "East US"
}

resource "azurerm_storage_account" "storage" {
  name = "${var.prefix}storage903845"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_kind = "StorageV2"
  account_tier = "Standard"
  account_replication_type = "LRS"
  infrastructure_encryption_enabled = true

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "container" {
  name = "${var.prefix}-state"
  storage_account_name = azurerm_storage_account.storage.name
}

output "rg-name" {
  value = azurerm_resource_group.rg.name
}
output "location" {
  value = azurerm_resource_group.rg.location
}
output "storage-name" {
  value = azurerm_storage_account.storage.name
}
output "storage-container" {
  value = azurerm_storage_container.container.name
}