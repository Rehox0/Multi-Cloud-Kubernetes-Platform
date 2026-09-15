########## Storage Account + Container (Analogue to S3 + DynamoDB) ##########
resource "azurerm_storage_account" "bootstrap" {
  name                     = var.state_storage_account_name 
  resource_group_name      = azurerm_resource_group.bootstrap.name
  location                 = azurerm_resource_group.bootstrap.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version = "TLS1_2"

  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy { days = 30 }
    container_delete_retention_policy { days = 30 }
  }
    # (Analogue to prevent_destroy)
  #lifecycle { prevent_destroy = true }

  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}

# Container for .tfstate
resource "azurerm_storage_container" "bootstrap" {
  name                  = var.storage_container_name
  storage_account_id    = azurerm_storage_account.bootstrap.id
  container_access_type = "private" # analogue to block_public_access
}
