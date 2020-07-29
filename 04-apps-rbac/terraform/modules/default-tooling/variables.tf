variable "cluster_name" {
  type        = string
  description = "Name of target cluster for tooling installation"
}

variable "longhorn_version" {
  type        = string
  description = "Version of longhorn to install"
  default     = "1.0.1"
}

variable "longhorn_answers" {
  type        = map(any)
  description = "Answers provided to Longhorn App"
  default     = {}
}

variable "kubectl_image" {
  type        = string
  description = "Image used for hyperkube image; override with private registry image for air-gap configurations, or specify any image that provides kubectl binary"
  default     = "rancher/hyperkube"
}

variable "kubectl_tag" {
  type        = string
  description = "Tag used for kubectl image, kubectl binary should match minor version of imported cluster; see https://hub.docker.com/r/rancher/hyperkube/tags for all available tags of default image, or provide custom image tag"
  default     = "v1.18.6-rancher1"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install"
  default     = "v0.15.0"
}

variable "cert_manager_crd_manifest_url" {
  type        = string
  description = "URL to cert-manager CRD YAML manifest; required to match with version of cert-manager being installed"
  default     = "https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml"
}

variable "elasticsearch_endpoint" {
  type        = string
  description = "Elasticsearch endpoint used for logging"
}

variable "elasticsearch_username" {
  type        = string
  description = "(Optional) Username for elasticsearch endpoint"
  default     = null
}

variable "elasticsearch_password" {
  type        = string
  description = "(Optional) Password for elasticsearch endpoint"
  default     = null
}
