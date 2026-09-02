resource "azurerm_public_ip" "jumpbox" {
  name                = "${var.project_name}-jumpbox-ip"
  resource_group_name = var.resource_group_name
  location            = var.location

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox-ip"
  })
}

resource "azurerm_network_security_group" "jumpbox" {
  name                = "${var.project_name}-jumpbox-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"

    source_port_range          = "*"
    destination_port_range     = "22"

    source_address_prefix      = "${var.admin_source_ip}/32"
    destination_address_prefix = "*"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox-nsg"
  })
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.project_name}-jumpbox-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox-nic"
  })
}

resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = azurerm_network_interface.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "${var.project_name}-jumpbox"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size

  admin_username = var.admin_username
  network_interface_ids = [ azurerm_network_interface.jumpbox.id ]
  disable_password_authentication = true

  identity { type = "SystemAssigned" }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/bootstrap.sh",{
    aks_resource_group = var.aks_resource_group
    aks_cluster_name   = var.aks_cluster_name

    kubectl_version    = var.kubectl_version
    kubectl_sha256     = var.kubectl_sha256

    kubelogin_version  = var.kubelogin_version
    kubelogin_sha256   = var.kubelogin_sha256

    helm_version       = var.helm_version
    helm_sha256        = var.helm_sha256
  }))


  tags = merge(var.common_tags, {
    Name = "${var.project_name}-jumpbox"
  })
}
