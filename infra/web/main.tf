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

data "terraform_remote_state" "global" {
  backend = "azurerm" 
  config = {
    resource_group_name  = "website-unchained"
    storage_account_name = "unchainedstorage903845"
    container_name       = "unchained-state"
    key                  = "global-workspace/terraform.tfstate"
  }
}

variable "prefix" {
  default = "unchained"
  type = string
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_storage_container" "static-container" {
  name = "static"
  storage_account_name = data.terraform_remote_state.global.outputs.storage-name
  container_access_type = "blob"
} 

resource "azurerm_cosmosdb_account" "db" {
  name                = "${var.prefix}-cosmos-db-${random_integer.ri.result}"
  location            = data.terraform_remote_state.global.outputs.location
  resource_group_name = data.terraform_remote_state.global.outputs.rg-name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableServerless"
  }

  capabilities {
    name = "DisableRateLimitingResponses"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location = "eastus"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "unchained-db" {
  name                = "unchained"
  resource_group_name = data.terraform_remote_state.global.outputs.rg-name
  account_name        = azurerm_cosmosdb_account.db.name
}

resource "azurerm_service_plan" "asp" {
  name                = "${var.prefix}-asp-${random_integer.ri.result}"
  location            = data.terraform_remote_state.global.outputs.location
  resource_group_name = data.terraform_remote_state.global.outputs.rg-name

  os_type = "Linux"
  sku_name = "B1"
}

resource "azurerm_linux_web_app" "web-app" {
  name                = "${var.prefix}-webapp-${random_integer.ri.result}"
  location            = data.terraform_remote_state.global.outputs.location
  resource_group_name = data.terraform_remote_state.global.outputs.rg-name
  service_plan_id = azurerm_service_plan.asp.id

  https_only = true

  site_config {
    minimum_tls_version = "1.2"

    application_stack {
      python_version = "3.10"
    }
  }
}

resource "azurerm_app_service_custom_hostname_binding" "custom-hostname" {
  hostname            = "cmeadows.tech"
  app_service_name    = azurerm_linux_web_app.web-app.name
  resource_group_name = data.terraform_remote_state.global.outputs.rg-name

  ssl_state           = "SniEnabled"
}

