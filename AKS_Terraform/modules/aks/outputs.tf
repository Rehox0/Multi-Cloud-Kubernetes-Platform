output "cluster_id" {
  description = "AKS cluster resource ID"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "AKS kubeconfig"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID of the AKS kubelet managed identity"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL used by AKS Workload Identity"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "private_dns_zone_id" {
  description = "Private DNS Zone ID used by the AKS private cluster"
  value       = azurerm_kubernetes_cluster.main.private_dns_zone_id
}

output "node_resource_group" {
  description = "Managed resource group created by AKS"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}