provider "aws" {
  version = "~> 2.70"

  profile = var.aws_profile
  # region  = var.aws_region
  region  = "us-east-2"
}

provider "local" {
  version = "~> 1.4"
}

provider "rancher2" {
  version = "~> 1.9"

  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

provider "random" {
  version = "~> 2.3"
}

provider "tls" {
  version = "~> 2.2"
}

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key_pem" {
  filename          = "${path.cwd}/id_rsa"
  sensitive_content = tls_private_key.global_key.private_key_pem
  file_permission   = "0400"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.cwd}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

resource "random_string" "uid" {
  length  = 6
  upper   = false
  number  = false
  special = false
}

module "custom_cluster" {
  source = "../../modules/private-aws-cluster"

  cluster_name    = "tf-mc-custom-${random_string.uid.result}"
  creator         = "nikkelma-admin"
  ssh_private_key = tls_private_key.global_key.private_key_pem
  ssh_public_key  = tls_private_key.global_key.public_key_openssh
}
