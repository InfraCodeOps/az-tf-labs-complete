# Create virtual network
resource "azurerm_virtual_network" "infra_vnet" {
  name                = "vnet-${local.app_code}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "infra_subnet" {
  name                 = "subnet-${local.app_code}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.infra_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP for the Load Balancer
resource "azurerm_public_ip" "infra_ip" {
  name                = "ip-${local.app_code}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Dynamic IP might not be available immediately
  # You might need to reapply config
  # For immediate availability, use Static
  allocation_method   = "Static"
}

# Azure Load Balancer
resource "azurerm_lb" "infra_lb" {
  name                = "lb-${local.app_code}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.infra_ip.id
  }
}

# Load Balancer Backend Pool
resource "azurerm_lb_backend_address_pool" "infra_lb_pool" {
  loadbalancer_id      = azurerm_lb.infra_lb.id
  name                = "infraBackendPool"
}

# Load Balancer Rule that allows HTTP traffic
resource "azurerm_lb_rule" "infra_lb_rule" {
  loadbalancer_id                = azurerm_lb.infra_lb.id
  name                          = "HTTP"
  protocol                      = "Tcp"
  frontend_port                 = 80
  backend_port                  = 80
  frontend_ip_configuration_name = azurerm_lb.infra_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.infra_lb_pool.id]

  probe_id = azurerm_lb_probe.infra_lb_probe.id

}

# Probe for the Load Balancer
resource "azurerm_lb_probe" "infra_lb_probe" {
  loadbalancer_id      = azurerm_lb.infra_lb.id
  name                = "httpProbe"
  protocol            = "Http"
  port                = 80
  request_path        = "/"
#   interval_in_seconds = 5
#   number_of_probes    = 2
}

resource "azurerm_network_security_group" "infra_nsg" {
  name                = "nsg-${local.app_code}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "infra_nsg_association" {
  subnet_id                 = azurerm_subnet.infra_subnet.id
  network_security_group_id = azurerm_network_security_group.infra_nsg.id
}

