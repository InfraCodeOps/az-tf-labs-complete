# A random prefix for App Service Plan name
resource "random_string" "app_prefix" {
  length  = 4
  special = false
  upper   = false
}

# Create a Linux Service Plan for the Web App
resource "azurerm_service_plan" "infra_app_service_plan" {
  name                = "${random_string.app_prefix.result}-infra-service-plan"
  resource_group_name = azurerm_resource_group.infra_rg.name
  location            = azurerm_resource_group.infra_rg.location
  sku_name = "B2"
  os_type = "Linux"
}

# linux web app
resource "azurerm_linux_web_app" "infra-web-app" {
  name                = "${random_string.app_prefix.result}-demo-app"
  resource_group_name = azurerm_resource_group.infra_rg.name
  location            = azurerm_service_plan.infra_app_service_plan.location
  service_plan_id     = azurerm_service_plan.infra_app_service_plan.id
  site_config {}

  # We will use the app_settings to set the WEBSITE_RUN_FROM_PACKAGE
  # to the URL of the zip file we will upload to the storage account
  # In real-world scenarios, you'd use a git repository and a CICD pipeline
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = azurerm_storage_blob.infra_site_zip_blob.url
  }
}

# Let's create a zip file of the site's content
# We basically need to zip up index.html
data "archive_file" "infra_site_zip" {
  type        = "zip"
  source_file  = "${path.module}/index.html"
  output_path = "${path.module}/site.zip"
}

# Upload the zip file to the storage container created earlier
# Note: For the sake of simplicity, we are directly uploading a zip file
# to the storage account. In a real-world scenario, you would use a git
# repository and a CICD pipeline to automate this process with 
resource "azurerm_storage_blob" "infra_site_zip_blob" {
  name                   = "site.zip"
  storage_account_name   = azurerm_storage_account.infra_sa.name
  storage_container_name = azurerm_storage_container.infra_container.name
  type                   = "Block"
  source                 = data.archive_file.infra_site_zip.output_path 
}


# Validate that the web app is running with this URL
# Sometimes it takes a few minutes for the web app to be available
output "website_url" {
  value = azurerm_linux_web_app.infra-web-app.default_hostname
}

output "blob_url" {
  value = azurerm_storage_blob.infra_site_zip_blob.url
}