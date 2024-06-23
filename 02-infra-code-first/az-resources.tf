
# Terraform Configuration Block
# We will look at configuration block in detail in upcoming labs
provider "azurerm" {
  features {}
}

# Definition of Azure Resource Group
resource "azurerm_resource_group" "infra_rg" {
  name     = "infra-rg-02"
  location = "centralus"
}

# Definition of Azure Virtual Network within Azure Resource Group
resource "azurerm_virtual_network" "infra_vnet" {
  name                = "main-vnet-${random_string.hello-random.result}"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name
  address_space       = ["10.0.0.0/16"]

  # Tagging the Azure Virtual Network
  tags = {
    Name = "main-vnet-${random_string.hello-random.result}"
  }
}
