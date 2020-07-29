provider "azurerm" {
  version = "~> 2.20"

  features {}

  subscription_id = var.azurerm_subscription_id
  client_id       = var.azurerm_client_id
  client_secret   = var.azurerm_client_secret
  tenant_id       = var.azurerm_tenant_id
}

provider "random" {
  version = "~> 2.3"
}

resource "random_string" "uid" {
  length  = 6
  upper   = false
  number  = false
  special = false
}

module "basic_aks_cluster" {
  source = "../../modules/basic-aks-cluster"

  prefix   = "tf-mc-${random_string.uid.result}"
  location = var.location
}
