output "id" {
  value = azurerm_lb.main.id
}

output "name" {
  value = azurerm_lb.main.name
}

output "frontend_ip" {
  value = azurerm_lb.main.frontend_ip_configuration[0].private_ip_address
}

output "frontend_ip_configuration_id" {
  value = azurerm_lb.main.frontend_ip_configuration[0].id
}