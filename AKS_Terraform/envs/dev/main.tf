module "networking" {
  source = "../../modules/networking"

  project_name        = var.project_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  vnet_cidr        = "10.20.0.0/16"
  aks_subnet_cidrs = ["10.20.4.0/22", "10.20.8.0/22"]
  private_link_subnet_cidr = "10.20.12.0/24"
  jumpbox_network = {
    location    = "polandcentral"
    vnet_cidr   = "10.10.0.0/16"
    subnet_cidr = "10.10.0.0/24"
  }

  common_tags = local.tags
}

module "aks" {
  source = "../../modules/aks"

  project_name = var.project_name
  cluster_name = local.cluster_name

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  subnet_id           = module.networking.aks_subnets[0]
  private_dns_zone_id = module.networking.aks_private_dns_zone_id
  identity_id         = module.identity.aks_identity_id
  
  kubernetes_version = var.cluster_version

  node_vm_size = "Standard_D2s_v7"

  node_min_size = 2
  node_max_size = 2

  node_labels = {
    env = "dev"
  }
  common_tags = local.tags

  depends_on = [module.networking]
}

module "jumpbox" {
  source = "../../modules/jumpbox"

  project_name        = var.project_name
  location            = "polandcentral"

  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.networking.jumpbox_subnet_id

  vm_size           = "Standard_D2als_v6"
  priority          = "Spot"
  eviction_policy   = "Deallocate"
  max_bid_price     = -1

  ssh_public_key  = file("~/.ssh/id_ed25519.pub")
  admin_username  = "azureadmin"
  admin_source_ip = var.admin_source_ip

  kubectl_version   = var.kubectl_version
  kubectl_sha256    = var.kubectl_sha256
  kubelogin_version = var.kubelogin_version
  kubelogin_sha256  = var.kubelogin_sha256
  helm_version      = var.helm_version
  helm_sha256       = var.helm_sha256

  common_tags = local.tags

  depends_on = [module.aks]
}

module "identity" {
  source = "../../modules/identity"

  project_name = var.project_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  aks_private_dns_zone_id = module.networking.aks_private_dns_zone_id
  aks_vnet_id             = module.networking.aks_vnet_id
  backend_keyvault_id     = module.key_vault.id
  backend_identity_principal_id = data.terraform_remote_state.bootstrap.outputs.backend_identity_principal_id

  user_object_id          = var.user_object_id
  common_tags = local.tags
}

module "key_vault" {
  source = "../../modules/key_vault"

  project_name       = var.project_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  common_tags = local.tags
}

module "gateway_lb" {
  source = "../../modules/gateway_lb"

  project_name        = var.project_name
  resource_group_name = module.aks.node_resource_group
  location            = var.location
  aks_subnet_id = module.networking.aks_subnets[0]
aks_vmss_id   = module.aks.vmss_resources[0].id
aks_vmss_name = module.aks.vmss_resources[0].name

  protocol            = "Tcp"
  gateway_frontend_port = 80
  gateway_node_port     = 32767

  common_tags = local.tags

  depends_on = [
    module.aks,
    module.networking
  ]
}

module "front_door" {
  count  = var.enable_frontdoor ? 1 : 0
  source = "../../modules/front_door"

  project_name            = var.project_name
  resource_group_name     = azurerm_resource_group.main.name

  gateway_lb_frontend_ip = module.gateway_lb.frontend_ip
  gateway_lb_frontend_ip_configuration_id = module.gateway_lb.frontend_ip_configuration_id
  
  private_link_location = "germanywestcentral"
  private_link_subnet_id = module.networking.private_link_subnet_id

  common_tags = local.tags

  depends_on = [
    module.gateway_lb,
    module.networking
  ]
}

module "traffic_manager" {
  source = "../../modules/traffic_manager"

  project_name        = var.project_name
  resource_group_name = azurerm_resource_group.main.name

  aws_cloudfront_hostname = var.aws_cloudfront_hostname

  azure_frontdoor_hostname = module.front_door[0].endpoint_hostname

  health_probe_path = "/api/health"

  common_tags = local.tags

  depends_on = [
    module.front_door
  ]
}
