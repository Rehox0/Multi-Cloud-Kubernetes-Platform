output "loki_identity_client_id" {
  description = "Client ID of the Loki managed identity"
  value       = module.loki_storage.loki_identity_client_id
}