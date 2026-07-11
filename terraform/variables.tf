# =============================================================================
# variables.tf - Variables reutilizables del proyecto
# =============================================================================

variable "subscription_id" {
  description = "ID de la suscripción de Azure (cuenta de estudiante)"
  type        = string
}

variable "region_azure" {
  description = "Región de Azure donde se despliegan los recursos (evitar West Europe, bloqueada en cuentas de estudiante)"
  type        = string
  default     = "swedencentral"
}

variable "nombre_grupo_recursos" {
  description = "Nombre del grupo de recursos que contendrá toda la infraestructura del caso práctico"
  type        = string
  default     = "rg-casopractico2"
}

variable "nombre_acr" {
  description = "Nombre del Azure Container Registry (debe ser único a nivel global y en minúsculas)"
  type        = string
}

variable "sku_acr" {
  description = "Nivel de servicio (SKU) del ACR"
  type        = string
  default     = "Basic"
}

variable "tag_imagenes" {
  description = "Tag obligatorio para las imágenes del caso práctico"
  type        = string
  default     = "casopractico2"
}
