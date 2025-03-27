


# RSA key of size 4096 bits


resource "tls_private_key" "rsa-2048" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "private_key" {
  content  = tls_private_key.rsa-2048.private_key_pem
  filename = "${path.root}/${var.path_ssh}/${var.name}.pem"
  file_permission = 0600
}