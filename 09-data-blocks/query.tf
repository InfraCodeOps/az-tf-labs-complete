data "azurerm_platform_image" "example" {
  location  = "centralus"
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-azure-edition-core"
  version = "20348.2402.240607"
}

output "id" {
  value = data.azurerm_platform_image.example.id
}