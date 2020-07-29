
resource "rancher2_cluster" "target" {
  name = var.cluster_name
  rke_config {
    kubernetes_version = "v1.17.9-rancher1-1"
  }
}

resource "rancher2_node_template" "target" {
  for_each = var.node_pools

  name                = "${var.cluster_name}-nt-${each.value.prefix}"
  cloud_credential_id = each.value.cloud_credential_id
  digitalocean_config {
    image    = each.value.image
    region   = each.value.region
    size     = each.value.size
    ssh_user = each.value.ssh_user
  }
  engine_install_url = "https://releases.rancher.com/install-docker/19.03.sh"
}

resource "rancher2_node_pool" "target" {
  for_each = var.node_pools

  cluster_id       = rancher2_cluster.target.id
  name             = "${var.cluster_name}-np-${each.value.prefix}"
  hostname_prefix  = each.value.prefix
  node_template_id = rancher2_node_template.target[each.key].id
  control_plane    = each.value.control_plane
  etcd             = each.value.etcd
  worker           = each.value.worker
}

