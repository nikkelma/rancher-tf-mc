output "resource_group_name" {
  value = module.basic_aks_cluster.resource_group_name
}

output "cluster_name" {
  value = module.basic_aks_cluster.cluster_name
}

output "prefix" {
  value = random_string.uid.result
}

