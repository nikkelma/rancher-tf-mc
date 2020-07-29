variable "aws_profile" {
  type        = string
  description = "Name of AWS CLI profile to use for authentication"
}

# variable "aws_region" {
#   type        = string
#   description = "Region used for all AWS resources"
# }

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

variable "creator" {
  type        = string
  description = "Creator used for all applicable AWS resources"
}
