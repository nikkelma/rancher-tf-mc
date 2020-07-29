output "resource_group_name" {
  value = azurerm_resource_group.target.name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.target.name
}
