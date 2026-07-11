# =============================================================================
# red.tf - Red virtual, subred y grupo de seguridad (NSG) para la VM
# Elemento 2 del caso práctico: máquina virtual Linux accesible desde Internet
# =============================================================================

resource "azurerm_virtual_network" "red_virtual" {
  name                = "vnet-casopractico2"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.grupo_recursos.location
  resource_group_name = azurerm_resource_group.grupo_recursos.name

  tags = {
    entorno = "casopractico2"
    sesion  = "2"
  }
}

resource "azurerm_subnet" "subred_vm" {
  name                 = "subnet-vm"
  resource_group_name  = azurerm_resource_group.grupo_recursos.name
  virtual_network_name = azurerm_virtual_network.red_virtual.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Grupo de seguridad de red: solo abrimos lo estrictamente necesario
# (principio de mínimo privilegio exigido en la Sesión 2).
resource "azurerm_network_security_group" "firewall_vm" {
  name                = "nsg-vm-web"
  location            = azurerm_resource_group.grupo_recursos.location
  resource_group_name = azurerm_resource_group.grupo_recursos.name

  security_rule {
    name                       = "permitir-ssh"
    priority                  = 100
    direction                 = "Inbound"
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "permitir-https"
    priority                  = 110
    direction                 = "Inbound"
    access                    = "Allow"
    protocol                  = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "443"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  tags = {
    entorno = "casopractico2"
    sesion  = "2"
  }
}

resource "azurerm_subnet_network_security_group_association" "asociacion_nsg" {
  subnet_id                 = azurerm_subnet.subred_vm.id
  network_security_group_id = azurerm_network_security_group.firewall_vm.id
}

resource "azurerm_public_ip" "ip_publica_vm" {
  name                = "ip-vm-web"
  location            = azurerm_resource_group.grupo_recursos.location
  resource_group_name = azurerm_resource_group.grupo_recursos.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    entorno = "casopractico2"
    sesion  = "2"
  }
}

resource "azurerm_network_interface" "nic_vm" {
  name                = "nic-vm-web"
  location            = azurerm_resource_group.grupo_recursos.location
  resource_group_name = azurerm_resource_group.grupo_recursos.name

  ip_configuration {
    name                          = "config-ip"
    subnet_id                     = azurerm_subnet.subred_vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip_publica_vm.id
  }

  tags = {
    entorno = "casopractico2"
    sesion  = "2"
  }
}
