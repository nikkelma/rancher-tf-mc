provider "rancher2" {
  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

provider "random" {
}

resource "random_string" "uid" {
  length  = 6
  upper   = false
  number  = false
  special = false
}

data "rancher2_node_template" "v01_small" {
  name = "nikkelma-vmware-ubuntu-s"
}

data "rancher2_node_template" "v01_default" {
  name = "nikkelma-vmware-ubuntu"
}

module "node_driver_cluster" {
  source = "../../modules/generic-node-driver-cluster"

  cluster_name = "tf-mc-driver-${random_string.uid.result}"
  node_pools = {
    v01_master = {
      "prefix"           = "v01m"
      "node_template_id" = data.rancher2_node_template.v01_small.id
      "quantity"         = 3
      "control_plane"    = true
      "etcd"             = true
      "worker"           = false
    }
    v01_worker = {
      "prefix"           = "v01w"
      "node_template_id" = data.rancher2_node_template.v01_default.id
      "quantity"         = 2
      "control_plane"    = false
      "etcd"             = false
      "worker"           = true
    }
    # v02_master = {
    #   "prefix"           = "v02m"
    #   "node_template_id" = data.rancher2_node_template.v01_default.id
    #   "quantity"         = 3
    #   "control_plane"    = true
    #   "etcd"             = true
    #   "worker"           = false
    # }
  }
}
