

output "public_ssh_key_openssh" {
 value = tls_private_key.rsa-2048.public_key_openssh
}

output "public_ssh_key_pem" {
  value = tls_private_key.rsa-2048.public_key_pem
}


output "private_ssh_key_pem" {
  value = tls_private_key.rsa-2048.private_key_pem
}
