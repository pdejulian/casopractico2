# =============================================================================
# aks.tf - Cluster de Kubernetes gestionado (AKS)
# =============================================================================
# Azure gestiona el plano de control (API Server, etcd, scheduler); nosotros
# solo gestionamos el/los nodos worker y las apps que se despliegan encima.
# sku_tier = "Free": evita el SLA de pago del plano de control, recomendado
# para el tier de Azure for Students.
# =============================================================================

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.nombre_aks
  resource_group_name = azurerm_resource_group.grupo_recursos.name
  location            = azurerm_resource_group.grupo_recursos.location
  dns_prefix          = var.dns_prefix_aks
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = var.numero_nodos_aks
    vm_size    = var.tamano_nodo_aks
  }

  # Identidad administrada por Azure (SystemAssigned): la usaremos para
  # asignarle el rol AcrPull sobre el ACR sin necesidad de secretos.
  identity {
    type = "SystemAssigned"
  }

  tags = {
    entorno = "casopractico2"
    sesion  = "3"
  }
}
