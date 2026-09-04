resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix          = var.cluster_name

  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled   = true
  
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # ----------------------------------------------------------
  # Default node pool
  # ----------------------------------------------------------

  default_node_pool {
    name = "system"

    vm_size = var.node_vm_size

    min_count = var.node_min_size
    max_count = var.node_max_size

    auto_scaling_enabled = true

    vnet_subnet_id = var.subnet_id

    node_labels = merge(
      {
        role = "worker"
      },
      var.node_labels
    )

    upgrade_settings {
      max_surge = "10%"
      drain_timeout_in_minutes = 0
      node_soak_duration_in_minutes = 0
    }
  }

  # ----------------------------------------------------------
  # Identity
  # ----------------------------------------------------------

  identity {
    type = "SystemAssigned"
  }

  # ----------------------------------------------------------
  # Networking
  # ----------------------------------------------------------

  network_profile {
    network_plugin = "none"

    load_balancer_sku = "standard"

    outbound_type  = "userAssignedNATGateway"

    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  # ----------------------------------------------------------
  # Tags
  # ----------------------------------------------------------

  tags = var.common_tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}