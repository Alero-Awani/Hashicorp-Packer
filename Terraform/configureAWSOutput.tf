output "privateKey" {
  value = "${tls_private_key.packer_private_key.private_key_pem}"
}