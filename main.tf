locals {
  rg_name     = var.DEFAULT_RESOURCE_GROUP_NAME != null ? data.azurerm_resource_group.rg[0].name : "resource-group-${var.DOMAIN_NAME}"
  rg_location = var.DEFAULT_RESOURCE_GROUP_NAME != null ? data.azurerm_resource_group.rg[0].location : var.LOCATION
  workers     = [for n in range(1, var.worker["numbers"] + 1) : "${var.worker["name"]}-${n}"]
  clusters    = { for c in concat([var.master], local.workers) : c => c }
}

module "network" {
  source      = "./modules/network"
  rg_location = local.rg_location
  rg_name     = local.rg_name
}

module "vm" {
  for_each = local.clusters

  source        = "./modules/vm"
  rg_location   = local.rg_location
  rg_name       = local.rg_name
  computer_name = each.value
  nsg_id        = module.network.nsg_id
  subnet_id     = module.network.subnet_id
  username      = var.adminuser
}


resource "terraform_data" "master_provisionner" {


  provisioner "remote-exec" {
    connection {
      host        = module.vm[var.master].public-ip
      private_key = module.vm[var.master].private-ssh-key
      user        = var.adminuser
      type        = "ssh"
    }
    script = "scripts/master.sh"
  }

  provisioner "local-exec" {
    command = <<-EOT
            scp -o "StrictHostKeyChecking no" -i ./ssh_dir/${local.clusters[var.master]}.pem ${var.adminuser}@${module.vm[var.master].public-ip}:/home/${var.adminuser}/join.sh ./scripts/join.sh
            scp -o "StrictHostKeyChecking no" -i ./ssh_dir/${local.clusters[var.master]}.pem ${var.adminuser}@${module.vm[var.master].public-ip}:/home/${var.adminuser}/.kube/config $HOME/.kube/config
            sed -i "" "s/${module.vm[var.master].private-ip}/kubernetes/" $HOME/.kube/config
            ssh  -fNL 6443:${module.vm[var.master].private-ip}:6443 -i ./ssh_dir/${local.clusters[var.master]}.pem ${var.adminuser}@${module.vm[var.master].public-ip}
    EOT
  }
}


resource "terraform_data" "nodes_provisionner" {
  for_each = { for w in local.workers : w => w }

  provisioner "remote-exec" {
    connection {
      host        = module.vm[each.key].public-ip
      private_key = module.vm[each.key].private-ssh-key
      user        = var.adminuser
      type        = "ssh"
    }
    script     = "scripts/join.sh"
    on_failure = fail
  }

  depends_on = [terraform_data.master_provisionner]
}