# =============================================================================
# aks-acr.tf - Integracion de AKS con el ACR (permiso de pull)
# =============================================================================
# Por defecto, AKS no puede descargar imagenes de un ACR privado: el pod se
# queda en ImagePullBackOff. La forma limpia (sin secretos en los YAML) es
# asignar el rol "AcrPull" a la identidad del kubelet (agent pool), que es
# quien realmente hace el "pull" de las imagenes, NO a la identidad del
# plano de control. Este es el patron recomendado por Microsoft, equivalente
# a "az aks update --attach-acr".
# =============================================================================

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.registro_imagenes.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  # Evita que Terraform intente comprobar el principal en Azure AD antes de
  # que la identidad del kubelet este totalmente propagada (puede tardar).
  skip_service_principal_aad_check = true
}
