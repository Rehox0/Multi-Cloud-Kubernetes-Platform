resource "azurerm_storage_account" "loki" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true

  tags = var.common_tags
}

resource "azurerm_storage_container" "chunks" {
  name                  = "loki-chunks"
  storage_account_id    = azurerm_storage_account.loki.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "ruler" {
  name                  = "loki-ruler"
  storage_account_id    = azurerm_storage_account.loki.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "admin" {
  name                  = "loki-admin"
  storage_account_id    = azurerm_storage_account.loki.id
  container_access_type = "private"
}