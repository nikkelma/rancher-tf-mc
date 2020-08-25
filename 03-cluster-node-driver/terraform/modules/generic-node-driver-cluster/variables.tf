variable "cluster_name" {
  type        = string
  description = "Name of created cluster"
}

variable "node_pools" {
  type = map(
    object({
      prefix           = string,
      node_template_id = string,
      quantity         = number,
      control_plane    = bool,
      etcd             = bool,
      worker           = bool,
    })
  )
  description = "Configuration of node pools for created cluster"
}
