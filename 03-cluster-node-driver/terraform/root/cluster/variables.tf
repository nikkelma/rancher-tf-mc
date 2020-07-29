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

variable "do_access_token" {
  type        = string
  description = "Access token used for Rancher DigitalOcean cloud credential"
}
