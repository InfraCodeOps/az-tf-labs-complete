# random string of size 8, alphanumeric for storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

# Storage account for storing data
resource "azurerm_storage_account" "infra_sa" {
  name                     = "${var.storage_prefix}store${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.infra_rg.name
  location                 = azurerm_resource_group.infra_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# output the storage account name:
output "storage_account_name" {
  value = azurerm_storage_account.infra_sa.name
}