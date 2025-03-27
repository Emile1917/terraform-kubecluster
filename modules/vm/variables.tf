variable "rg_name" {
  type = string
}

variable "rg_location" {
  type = string
}


variable "username" {
  description = "The username to be used in the configuration"
  type        = string
 
}

variable "computer_name" {
  description = "The name of the computer for the virtual machine"
  type        = string
}

variable "size" {
  type = string
  default = "Standard_D2s_v3"
  validation {
    condition = contains(["Standard_DS1_v2","Standard_DS3_v2","Standard_D2s_v3","Standard_D2","Standard_D1_v2","Standard_DS1_v2","Standard_DS1","Standard_F2","Standard_A0","Standard_A1v2"],var.size)
    error_message = "must be within those values"
  }
}

variable "os_disk" {
    type = map(string)
    default = {
    name                 = "OsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    }
  
  }

 variable "source_image_reference" {
    type = map(string)

    default = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

 }


variable "subnet_id" {
  type = string
}

variable "nsg_id" {
  type = string
}

