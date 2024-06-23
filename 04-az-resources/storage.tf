# random string of size 8, alphanumeric for storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Storage account for storing data
resource "azurerm_storage_account" "infra_sa" {
  name                     = "infrastore${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.infra_rg.name
  location                 = azurerm_resource_group.infra_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# A container in the storage account
resource "azurerm_storage_container" "infra_container" {
  name                 = "infracontainer"
  storage_account_name = azurerm_storage_account.infra_sa.name

  # This access level is private by default
  # but here we are explicitly setting it to blob
  # to validate the blob we will create in the next step
  # Best practice would be to keep it private
  container_access_type = "blob"
}

# a sample blob that we will upload to the container
# keep in mind, in real world Terraform is not used to manage application data
resource "azurerm_storage_blob" "infra_blob" {
  name                   = "hello.txt"
  storage_account_name   = azurerm_storage_account.infra_sa.name
  storage_container_name = azurerm_storage_container.infra_container.name
  type                   = "Block"
  source                 = "hello.txt"

  # this will trigger an update if the file content changes
  content_md5 = filemd5("hello.txt")

  # due to limitations of this resource block, changes to hello.txt will not be detected
  # unless you use content_md5 as shown above.  If you decide not to, you can
  # force replacement using: terraform apply -replace=azurerm_storage_blob.infra_blob
}

# output uri of the blob
output "infra_blob_uri" {
  value = azurerm_storage_blob.infra_blob.url
}

# You can use the following command to access the file content using curl:
#   curl -s $(terraform output -raw infra_blob_uri)
# Or save it as a new file using:
#   curl -o download.txt $(terraform output -raw infra_blob_uri)