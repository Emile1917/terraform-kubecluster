locals {
  rg_name = var.rg_name
  rg_location = var.rg_location
}

module "ssh" {
  source = "../ssh"
  name = var.computer_name
}

module "nic" {
  source = "../nic"
  nsg_id = var.nsg_id
  subnet_id = var.subnet_id
  rg_location = local.rg_location
  rg_name = local.rg_name
  name = var.computer_name
}

module "storage" {
  source = "../storage"
  rg_location = local.rg_location
  rg_name = local.rg_name
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "my_terraform_vm" {
  name                  = "${var.computer_name}-VM"
  location              = local.rg_location
  resource_group_name   = local.rg_name
  network_interface_ids = [module.nic.nic_id]
  size                  = var.size

  os_disk {
    name                 = "${var.computer_name}OsDisk"
    caching              =  var.os_disk["caching"]
    storage_account_type =  var.os_disk["storage_account_type"]
  }

  source_image_reference {
    publisher = var.source_image_reference["publisher"]
    offer     = var.source_image_reference["offer"]
    sku       = var.source_image_reference["sku"]
    version   = var.source_image_reference["version"]
  }

  computer_name  = var.computer_name
  admin_username = var.username

  admin_ssh_key {
    username   = var.username
    public_key = module.ssh.public_ssh_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = module.storage.storage_account_uri
  }

  provisioner "remote-exec" {
    connection {
      host = self.public_ip_address
      type = "ssh"
      private_key = module.ssh.private_ssh_key_pem
      user = self.admin_username
    }

    script = "scripts/common.sh"
  }
}