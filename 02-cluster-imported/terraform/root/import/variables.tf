
variable "azurerm_subscription_id" {
  type        = string
  description = "Azure subscription ID under which resources will be provisioned"
}

variable "azurerm_client_id" {
  type        = string
  description = "Azure client ID used to create resources"
}

variable "azurerm_client_secret" {
  type        = string
  description = "Client secret used to authenticate with Azure APIs"
}

variable "azurerm_tenant_id" {
  type        = string
  description = "Azure tenant ID used to create resources"
}

variable "azurerm_location" {
  type        = string
  description = "Azure location used for all resources"
  default     = "East US"
}

variable "rancher_api_url" {
  type        = string
  description = "API endpoint of target Rancher server"
}

variable "rancher_access_key" {
  type        = string
  description = "Access key used for authentication against target Rancher server"
}

variable "rancher_secret_key" {
  type        = string
  description = "Secret key used for authentication against target Rancher server"
}

variable "aks_cluster_resource_group_name" {
  type        = string
  description = "Name of resource group containing target"
}

variable "aks_cluster_name" {
  type        = string
  description = "Secret key used for authentication against target Rancher server"
}

variable "rancher_cluster_name" {
  type        = string
  description = "Name of created Rancher imported cluster"
}
