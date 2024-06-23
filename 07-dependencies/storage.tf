
# Ensure the storage account name is globally unique
# !!!You will need to change the name value below!!!
resource "azurerm_storage_account" "infra_sa" {
 
  # SUGGESTION: add your initials at the end of the a 
  # name like "aztflab7sa". 
  # So, If your initials were js, name would be "aztflab7sajs"
  name                     = "aztflab7sajs"

  resource_group_name      = azurerm_resource_group.infra_rg.name
  location                 = azurerm_resource_group.infra_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    "Name" = "Lab7 Storage Account"
  }
}

resource "azurerm_storage_container" "infra_container" {
  name                  = "lab7container"

  # Reference your unique storage account name (e.g. aztflab7sa24js)
  # we are using a literal string here to play with dependencies
  storage_account_name  = "aztflab7sa24js"

  #In step 4, enable implicit dependency by replacing the line
  # above with the line below:
  # storage_account_name  = azurerm_storage_account.infra_sa.name


  container_access_type = "private"

  # Explicitly depend on the storage account
  depends_on = [ azurerm_storage_account.infra_sa ]
}