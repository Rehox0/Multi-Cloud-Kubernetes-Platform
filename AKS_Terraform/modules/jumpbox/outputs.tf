output "public_ip_address" {
  description = "Public IP address of the jumpbox"
  value       = azurerm_public_ip.jumpbox.ip_address
}

output "private_ip_address" {
  description = "Private IP address of the jumpbox"
  value       = azurerm_network_interface.jumpbox.private_ip_address
}

output "vm_id" {
  description = "Jumpbox VM resource ID"
  value       = azurerm_linux_virtual_machine.jumpbox.id
}

output "identity_principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = azurerm_linux_virtual_machine.jumpbox.identity[0].principal_id
}
