resource "azurerm_virtual_network" "infra_vnet" {
  name                = "infra-vnet"
  resource_group_name = azurerm_resource_group.infra_rg.name
  location            = azurerm_resource_group.infra_rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    "Name" = "Lab 4 Virtual Network"
  }
}

resource "azurerm_subnet" "infra_subnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "infra-subnet"
  resource_group_name  = azurerm_resource_group.infra_rg.name
  virtual_network_name = azurerm_virtual_network.infra_vnet.name
}

# Network Interface
resource "azurerm_network_interface" "infra_nic" {
  name                = "infra-nic"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.infra_subnet.id
    private_ip_address_allocation = "Dynamic"

    # optionally, associate a public IP address with the NIC
    # this requires a separate resource for the public IP address
    public_ip_address_id = azurerm_public_ip.infra_public_ip.id
  }
}

# Public IP to be associated with the VM Nic
resource "azurerm_public_ip" "infra_public_ip" {
  name                = "infra-public-ip"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name
  allocation_method   = "Dynamic"
}

# Network Security Group that allows inbound RDP and Web access
resource "azurerm_network_security_group" "infra_nsg" {
  name                = "infra-nsg"
  location            = azurerm_resource_group.infra_rg.location
  resource_group_name = azurerm_resource_group.infra_rg.name


  # Heads up, in a production environment,
  # you would want to restrict the source_address_prefix
  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Heads up, in a production environment,
  # you would want to restrict the source_address_prefix
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate the NSG with the NIC
resource "azurerm_network_interface_security_group_association" "infra_nsg_association" {
  network_interface_id      = azurerm_network_interface.infra_nic.id
  network_security_group_id = azurerm_network_security_group.infra_nsg.id
}