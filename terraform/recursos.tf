# =============================================================================
# recursos.tf - Azure Container Registry (ACR)
# Elemento 1 del caso práctico: repositorio privado de imágenes de contenedores
# =============================================================================

resource "azurerm_container_registry" "registro_imagenes" {
  name                = var.nombre_acr
  resource_group_name = azurerm_resource_group.grupo_recursos.name
  location            = azurerm_resource_group.grupo_recursos.location
  sku                 = var.sku_acr

  # Autenticación simple con usuario/contraseña de administrador.
  # Suficiente para este caso práctico; en producción se recomendaría
  # usar identidad gestionada o tokens con scope map.
  admin_enabled = true

  tags = {
    entorno = "casopractico2"
    sesion  = "1"
  }
}
