# =============================================================================
# outputs.tf - Datos que necesitaremos para construir y subir imágenes
# =============================================================================

output "acr_login_server" {
  description = "URL del registro (servidor de login) del ACR"
  value       = azurerm_container_registry.registro_imagenes.login_server
}

output "acr_admin_username" {
  description = "Usuario administrador del ACR"
  value       = azurerm_container_registry.registro_imagenes.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Contraseña administrador del ACR"
  value       = azurerm_container_registry.registro_imagenes.admin_password
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Outputs de la Sesión 2
# -----------------------------------------------------------------------------

output "ip_publica_vm" {
  description = "IP pública de la máquina virtual del servidor web"
  value       = azurerm_public_ip.ip_publica_vm.ip_address
}
