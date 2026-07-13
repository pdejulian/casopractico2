# =============================================================================
# generado.tf - Genera automaticamente los ficheros que necesita Ansible
# =============================================================================

resource "local_file" "inventario_ansible" {
  filename = "${path.module}/../ansible/hosts"

  content = templatefile("${path.module}/templates/hosts.tpl", {
    ip_publica     = azurerm_public_ip.ip_publica_vm.ip_address
    usuario_admin  = var.usuario_admin_vm
    ruta_clave_privada = abspath("${path.module}/../ansible/clave_ssh_vm")
  })
  depends_on = [local_file.clave_privada_ssh]
}

resource "local_file" "variables_ansible" {
  filename = "${path.module}/../ansible/group_vars/all.yml"

  content = templatefile("${path.module}/templates/all_yml.tpl", {
    acr_login_server = azurerm_container_registry.registro_imagenes.login_server
    acr_username      = azurerm_container_registry.registro_imagenes.admin_username
    acr_password      = azurerm_container_registry.registro_imagenes.admin_password
    image_tag         = var.tag_imagenes
  })

  file_permission = "0600"   # solo lectura/escritura para el propietario
}
