resource "azurerm_key_vault" "backend" {
  name                = "${var.project_name}-kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  sku_name = "standard"

  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  rbac_authorization_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-kv"
  })
}