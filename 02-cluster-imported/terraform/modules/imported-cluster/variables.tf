variable "rancher_cluster_name" {
  type        = string
  description = "Name of newly created Rancher imported cluster"
}

variable "kubectl_image" {
  type        = string
  default     = "rancher/hyperkube"
  description = "Image used for hyperkube image; override with private registry image for air-gap configurations, or specify any image that provides kubectl binary"
}

variable "kubectl_tag" {
  type        = string
  default     = "v1.18.6-rancher1"
  description = "Tag used for kubectl image, kubectl binary should match minor version of imported cluster; see https://hub.docker.com/r/rancher/hyperkube/tags for all available tags of default image, or provide custom image tag"
}
