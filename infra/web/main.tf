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

resource "azurerm_container_group" "example" {
  name                = "${var.prefix}-container-${random_integer.ri.result}"
  location            = data.terraform_remote_state.global.outputs.location
  resource_group_name = data.terraform_remote_state.global.outputs.rg-name
  ip_address_type     = "Public"
  dns_name_label      = "test-${random_integer.ri.result}"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }

  container {
    name   = "sidecar"
    image  = "mcr.microsoft.com/azuredocs/aci-tutorial-sidecar"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = {
    environment = "testing"
  }
}