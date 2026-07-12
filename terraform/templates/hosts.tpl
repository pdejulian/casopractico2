# =============================================================================
# hosts - Inventario de Ansible (GENERADO AUTOMATICAMENTE por Terraform)
# NO editar a mano: se sobrescribe en cada "terraform apply".
# =============================================================================

[podman_vm]
vm-web ansible_host=${ip_publica}

[podman_vm:vars]
ansible_user=${usuario_admin}
ansible_ssh_private_key_file=${ruta_clave_privada}
ansible_python_interpreter=/usr/bin/python3
