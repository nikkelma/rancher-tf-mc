output "rancher_cluster_id" {
  value       = module.imported_cluster.rancher_cluster_id
  description = "ID of newly created Rancher cluster"
}
