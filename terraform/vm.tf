# =============================================================================
# vm.tf - Máquina virtual Linux (Ubuntu Server) para el servidor web en Podman
# =============================================================================

resource "azurerm_linux_virtual_machine" "maquina_virtual_web" {
  name                = var.nombre_vm
  resource_group_name = azurerm_resource_group.grupo_recursos.name
  location            = azurerm_resource_group.grupo_recursos.location
  size                = var.tamano_vm
  admin_username      = var.usuario_admin_vm

  network_interface_ids = [
    azurerm_network_interface.nic_vm.id,
  ]

  # Solo autenticación por clave SSH: sin contraseñas, más seguro.
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.usuario_admin_vm
    public_key = file(var.ruta_clave_publica_ssh)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    entorno = "casopractico2"
    sesion  = "2"
  }
}
