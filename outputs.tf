
output "private-ip" {
    value = [for vm in module.vm : vm.private-ip]
}

output "public-ip" {
    value = [for vm in module.vm : vm.public-ip]
}

output "name" {
  value = [for vm in module.vm : vm.name]
}