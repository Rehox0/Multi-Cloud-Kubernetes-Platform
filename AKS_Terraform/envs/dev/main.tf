module "vnet" {
  source = "../../modules/vnet"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_cidr        = "10.0.0.0/16"
  aks_subnet_cidrs = ["10.0.0.0/22", "10.0.4.0/22"]

  cluster_name = local.cluster_name
  tags         = local.tags
}

module "aks" {
  source = "../../modules/aks"

  project_name = var.project_name
  cluster_name = local.cluster_name

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  subnet_id = module.vnet.aks_subnets[0]

  kubernetes_version = var.cluster_version

  node_vm_size = "Standard_B2s_v2"

  node_desired_size = 2
  node_min_size     = 1
  node_max_size     = 2

  node_labels = {
    env = "dev"
  }

  common_tags = local.tags
}
