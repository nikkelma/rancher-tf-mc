variable "cluster_name" {
  type        = string
  description = "Name of created cluster"
}

variable "node_pools" {
  type = map(
    object({
      cloud_credential_id = string,
      image               = string,
      region              = string,
      size                = string,
      ssh_user            = string,
      prefix              = string,
      quantity            = number,
      control_plane       = bool,
      etcd                = bool,
      worker              = bool,
    })
  )
  description = "Configuration of node pools for created cluster"
}
