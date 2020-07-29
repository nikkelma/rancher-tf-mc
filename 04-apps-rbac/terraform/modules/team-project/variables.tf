variable "cluster_name" {
  type        = string
  description = "Name of target cluster"
}

variable "project_name" {
  type        = string
  description = "Name of created project"
}

variable "namespace_names" {
  type        = list(string)
  description = "List of namespaces to create in project"
}

variable "project_owner_principals" {
  type        = map(string)
  description = "Map of users to assign Project Owner role; key will be used in role binding name"
  default     = {}
}

variable "project_member_principals" {
  type        = map(string)
  description = "Map of users to assign Project Member role; key will be used in role binding name"
  default     = {}
}
