variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}

variable "address_space" {
 type = list(string) 
 default = [ "10.0.0.0/16" ]
}

variable "name" {
  type = string
  default = "kube"
}

variable "allocation" {
  type = map(string)
  default = {
    "public" = "Dynamic"
    "private" = "Static"
  }
}

variable "security_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }) )

  default = [{
    name                       = "AllowIboundSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } ,
  {
    name                       = "AllowInboundIcmp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } ,
  {
    name                       = "AllowInboundKube"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  } ,
  {
    name                       = "AllowKubeservices"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-60000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  
    ]
}