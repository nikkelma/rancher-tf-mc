resource "rancher2_cluster" "target" {
  name = var.cluster_name
  rke_config {
    kubernetes_version = "v1.17.9-rancher1-1"
  }
}

resource "rancher2_node_pool" "target" {
  for_each = var.node_pools

  cluster_id       = rancher2_cluster.target.id
  name             = "${var.cluster_name}-np-${each.value.prefix}"
  hostname_prefix  = "${var.cluster_name}-${each.value.prefix}-"
  node_template_id = each.value.node_template_id
  quantity         = each.value.quantity
  control_plane    = each.value.control_plane
  etcd             = each.value.etcd
  worker           = each.value.worker
}

resource "rancher2_cluster_sync" "target" {
  cluster_id = rancher2_cluster.target.id
  node_pool_ids = [
    for pool in rancher2_node_pool.target :
    pool.id
  ]
}
