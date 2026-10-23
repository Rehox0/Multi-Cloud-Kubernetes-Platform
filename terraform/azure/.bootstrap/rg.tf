resource "azurerm_resource_group" "bootstrap" {
  name     = "${var.project_name}-bootstrap-rg"
  location = var.location

  tags = {
    Project     = var.project_name
    Environment = "bootstrap"
    ManagedBy   = "Terraform"
  }
}