# Create a resource group
resource "azurerm_resource_group" "infra_rg" {
  name     = "infra-rg-03"
  location = "centralus"
}

# Create a virtual network and subnets
# Using the Azure Virtual Network module
module "vnet" {
  source = "Azure/vnet/azurerm"

  # Use version 4.1.0 and above up to but not including 5.0.0
  version = "~>4.1.0"

  vnet_name           = "infra-code-vnet"
  resource_group_name = azurerm_resource_group.infra_rg.name
  vnet_location       = azurerm_resource_group.infra_rg.location

  # We will talk about for_each later in the course
  use_for_each = true

  address_space   = ["10.0.0.0/16"]
  subnet_names    = ["subnet1", "subnet2", "subnet3"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

}

# To validate this network was created in Azure, run the following az cli command in the terminal
# az network vnet show --resource-group infra-rg-03 --name infra-code-vnet