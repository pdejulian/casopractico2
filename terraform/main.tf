# =============================================================================
# main.tf - Configuración del proveedor y grupo de recursos
# Caso Práctico 2 - Sesión 1: Registro de imágenes (ACR)
# =============================================================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# El subscription_id es obligatorio a partir de azurerm v4.
# Se recomienda exportarlo como variable de entorno:
# export ARM_SUBSCRIPTION_ID="$(az account show --query id -o tsv)"
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Grupo de recursos que agrupará todos los elementos del caso práctico
resource "azurerm_resource_group" "grupo_recursos" {
  name     = var.nombre_grupo_recursos
  location = var.region_azure

  tags = {
    entorno = "casopractico2"
    sesion  = "1"
  }
}
