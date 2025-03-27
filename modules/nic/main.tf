locals {
  rg_name = var.rg_name
  rg_location = var.rg_location
}


# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "${var.name}-PublicIP"
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = var.allocation["public"]
}


# Create network interface
resource "azurerm_network_interface" "my_terraform_nic" {
  name                = "${var.name}-NIC"
  location            = local.rg_location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "${var.name}-nic-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.allocation["private"]
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.my_terraform_nic.id
  network_security_group_id = var.nsg_id
}
