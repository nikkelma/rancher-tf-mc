
provider "azurerm" {
  version = "~> 2.20"

  features {}

  subscription_id = var.azurerm_subscription_id
  client_id       = var.azurerm_client_id
  client_secret   = var.azurerm_client_secret
  tenant_id       = var.azurerm_tenant_id
}

provider "rancher2" {
  version = "~> 1.9"

  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

data "azurerm_kubernetes_cluster" "target_cluster" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_cluster_resource_group_name
}

# configure kubernetes provider for target AKS cluster
provider "kubernetes" {
  version = "~> 1.11"

  load_config_file       = false
  host                   = data.azurerm_kubernetes_cluster.target_cluster.kube_config.0.host
  username               = data.azurerm_kubernetes_cluster.target_cluster.kube_config.0.username
  password               = data.azurerm_kubernetes_cluster.target_cluster.kube_config.0.password
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.target_cluster.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.target_cluster.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.target_cluster.kube_config.0.cluster_ca_certificate)
}

module "imported_cluster" {
  source = "../../modules/imported-cluster"

  rancher_cluster_name = var.rancher_cluster_name
}
