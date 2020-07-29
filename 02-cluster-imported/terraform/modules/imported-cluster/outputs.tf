output "rancher_cluster_id" {
  value       = rancher2_cluster.target.id
  description = "ID of newly created Rancher cluster"
}
