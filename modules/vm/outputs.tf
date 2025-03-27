output "private-ip" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.private_ip_address
}

output "public-ip" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
}

output "private-ssh-key" {
  value = module.ssh.private_ssh_key_pem
}

output "name" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.name
}