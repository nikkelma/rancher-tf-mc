variable "config_path" {
  type = string
  description = "Path to kube config for target cluster"
}

variable "rancher_hostname" {
  type = string
  description = "Hostname used for new Rancher server"
}

variable "rancher_password" {
  type = string
  description = "Password used for new Rancher server"
}
