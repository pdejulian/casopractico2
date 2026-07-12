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


# ---------------------------------------------------------------------------
# Variables de la Sesión 2 - Máquina virtual + Podman
# ---------------------------------------------------------------------------

variable "nombre_vm" {
  description = "Nombre de la máquina virtual que alojará el servidor web en Podman"
  type        = string
  default     = "vm-casopractico2"
}

variable "tamano_vm" {
  description = "Tamaño de la VM (serie B burstable, incluida en el free tier de estudiante)"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "usuario_admin_vm" {
  description = "Usuario administrador de la máquina virtual"
  type        = string
  default     = "azureuser"
}

variable "ruta_clave_ssh_publica" {
  description = "Ruta local a la clave pública SSH que se inyectará en la VM"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# -----------------------------------------------------------------------------
# Variables de la Sesion 3 - Kubernetes gestionado (AKS)
# -----------------------------------------------------------------------------

variable "nombre_aks" {
  description = "Nombre del cluster de Kubernetes gestionado (AKS)"
  type        = string
  default     = "aks-casopractico2"
}

variable "dns_prefix_aks" {
  description = "Prefijo DNS unico del cluster AKS"
  type        = string
  default     = "cp2aks"
}

variable "numero_nodos_aks" {
  description = "Numero de nodos worker del cluster (el enunciado exige 1 como minimo)"
  type        = number
  default     = 1
}

variable "tamano_nodo_aks" {
  description = "Tamano de la VM del nodo worker (2 vCPU, dentro de la cuota de 6 vCPU de Student)"
  type        = string
  default     = "Standard_D2s_v3"
}
