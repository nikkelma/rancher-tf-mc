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

variable "cert_manager_crd_manifest_url" {
  type        = string
  description = "URL to cert-manager CRD YAML manifest; required to match with version of cert-manager being installed"
  default     = "https://github.com/jetstack/cert-manager/releases/download/v0.15.0/cert-manager.crds.yaml"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of cert-manager to install"
  default     = "v0.15.0"
}

variable "rancher_release_channel" {
  type        = string
  description = "Rancher repository channel to use for install"
  default     = "stable"
}

variable "rancher_version" {
  type        = string
  description = "Version of Rancher to install"
  default     = "v2.4.5"
}

variable "rancher_hostname" {
  type        = string
  description = "Hostname for installed Rancher server"
}

variable "rancher_password" {
  type        = string
  description = "Password for local admin user"
}

variable "rancher_sets" {
  type = list(
    object({
      name  = string,
      value = string,
      type  = string,
    })
  )
  description = "Helm set name/value pairs for configuring Rancher chart options"
  default     = []
}
