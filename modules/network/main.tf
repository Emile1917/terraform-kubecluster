locals {
  rg_name     = var.rg_name
  rg_location = var.rg_location
}


# Create virtual network
resource "azurerm_virtual_network" "my_terraform_network" {
  name                = "${var.name}_Vnet"
  address_space       = var.address_space
  location            = local.rg_location
  resource_group_name = local.rg_name
}

# Create subnet
resource "azurerm_subnet" "my_terraform_subnet" {
  name                 = "${var.name}_Subnet"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.my_terraform_network.name
  address_prefixes     = [cidrsubnet(var.address_space[0], 8, 0)]
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "${var.name}_NetworkSecurityGroup"
  location            = local.rg_location
  resource_group_name = local.rg_name

  dynamic "security_rule" {
    for_each = var.security_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}
