# =============================================================================
# ssh.tf - Genera automaticamente el par de claves SSH para la VM
# =============================================================================
# En vez de depender de que quien ejecute el proyecto ya tenga una clave SSH
# generada a mano (~/.ssh/id_rsa), Terraform genera aqui su propio par de
# claves exclusivo para este proyecto. Así, "terraform apply" funciona sin
# ningun paso manual previo de SSH, cumpliendo el requisito de automatizacion
# total del enunciado.
# =============================================================================

resource "tls_private_key" "clave_ssh_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Guardamos la clave privada en el propio proyecto para que Ansible pueda
# usarla despues. NUNCA se sube a git (ver .gitignore).
resource "local_file" "clave_privada_ssh" {
  filename        = "${path.module}/../ansible/clave_ssh_vm"
  content         = tls_private_key.clave_ssh_vm.private_key_pem
  file_permission = "0600"
}

resource "local_file" "clave_publica_ssh" {
  filename = "${path.module}/../ansible/clave_ssh_vm.pub"
  content  = tls_private_key.clave_ssh_vm.public_key_openssh
}
