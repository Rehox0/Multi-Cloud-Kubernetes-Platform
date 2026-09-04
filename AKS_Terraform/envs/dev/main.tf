module "vnet" {
  source = "../../modules/vnet"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_cidr           = "10.0.0.0/16"
  aks_subnet_cidrs    = ["10.0.4.0/22", "10.0.8.0/22"]

  common_tags = local.tags
}

module "vnet_jumpbox" {
  source = "../../modules/vnet_jumpbox"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.main.name
  location            = "austriaeast"

  vnet_cidr           = "10.10.0.0/16"
  jumpbox_subnet_cidr = "10.10.0.0/24"

  common_tags = local.tags
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

  node_min_size     = 2
  node_max_size     = 2

  node_labels = {
    env = "dev"
  }

  common_tags = local.tags
}

module "jumpbox" {
  source = "../../modules/jumpbox"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.main.name
  location            = "austriaeast"

  subnet_id             = module.vnet_jumpbox.jumpbox_subnet_id
  kubectl_version       = var.kubectl_version
  kubectl_sha256        = var.kubectl_sha256
  kubelogin_version     = var.kubelogin_version
  kubelogin_sha256      = var.kubelogin_sha256
  helm_version          = var.helm_version
  helm_sha256           = var.helm_sha256

  ssh_public_key = file("~/.ssh/id_ed25519.pub")
  admin_username = "azureadmin"
  admin_source_ip = var.admin_source_ip

  vm_size = "Standard_B2ls_v2"

  common_tags = local.tags

  depends_on = [
    module.aks
  ]
}