provider "rancher2" {
  version = "~> 1.9"

  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

provider "random" {
  version = "~> 2.3"
}

resource "random_string" "uid" {
  length  = 6
  upper   = false
  number  = false
  special = false
}

resource "rancher2_cloud_credential" "target" {
  name = "cloud-cred-${random_string.uid.result}"
  digitalocean_credential_config {
    access_token = var.do_access_token
  }
}

locals {
  ubuntu_image = "ubuntu-18-04-x64"
}

module "node_driver_cluster" {
  source = "../../modules/do-node-driver-cluster"

  cluster_name = "tf-mc-do-driver-${random_string.uid.result}"
  node_pools = {
    v01_01 = {
      cloud_credential_id = rancher2_cloud_credential.target.id
      image               = local.ubuntu_image
      region              = "nyc3"
      size                = "s-2vcpu-4gb"
      ssh_user            = "root"
      prefix              = "tf-mc-do-nd-${random_string.uid.result}-m"
      quantity            = 1
      control_plane       = true
      etcd                = true
      worker              = false
    }
    v01_02 = {
      cloud_credential_id = rancher2_cloud_credential.target.id
      image               = local.ubuntu_image
      region              = "nyc3"
      size                = "s-4vcpu-8gb"
      ssh_user            = "root"
      prefix              = "tf-mc-do-nd-${random_string.uid.result}-w"
      quantity            = 1
      control_plane       = false
      etcd                = false
      worker              = true
    }
  }
}
