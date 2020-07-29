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


variable "location" {
  type        = string
  description = "Azure location used for all resources"
  default     = "East US"
}

