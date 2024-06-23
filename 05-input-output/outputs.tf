output "storage_account_name" {
  value = azurerm_storage_account.infra_sa.name
}

output "blob_endpoint" {
  value = azurerm_storage_account.infra_sa.primary_blob_endpoint
}