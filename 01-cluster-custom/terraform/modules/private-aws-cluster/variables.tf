variable "cluster_name" {
  type        = string
  description = "Name of created Rancher custom cluster; also used as a base name for all created resources"
}

variable "creator" {
  type        = string
  description = "Creator name used in all applicable resource Creator labels"
}

variable "ssh_private_key" {
  type        = string
  description = "PEM format private key used for authentication into all created EC2 instances"
}

variable "ssh_public_key" {
  type        = string
  description = "OpenSSH format public key used for authentication into all created EC2 instances"
}


