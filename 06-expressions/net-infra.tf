resource "azurerm_virtual_network" "infra_vnet" {
  name                = "infra-vnet"
  resource_group_name = azurerm_resource_group.infra_rg.name
  location            = azurerm_resource_group.infra_rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    "Name" = "Infra Virtual Network"
  }
}

variable "subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

# Creating four subnets using the variable subnet_cidrs
# Using count to create multiple resources
resource "azurerm_subnet" "infra_subnet" {
  count                = length(var.subnet_cidrs)
  address_prefixes     = [var.subnet_cidrs[count.index]]
  name                 = "demo-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.infra_rg.name
  virtual_network_name = azurerm_virtual_network.infra_vnet.name
}

# Expressions:
# Details of the Vnet: azurerm_virtual_network.infra_vnet
# Data type of the subnet_cidrs variable: type(var.subnet_cidrs)
# The address prefix values for the first subnet in the VNet: azurerm_subnet.infra_subnet[0].address_prefixes
# All subnets in the VNet: azurerm_subnet.infra_subnet
# Names of all subnets using for expression: [for subnet in azurerm_subnet.infra_subnet: subnet.name]
# Name of all subnets using splat expression: azurerm_subnet.infra_subnet[*].name
# Total Number of subnets: length(azurerm_subnet.infra_subnet)
# The current working directory: path.cwd
# Path to the current module: path.module
# Path to the root module: path.root