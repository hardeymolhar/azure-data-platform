
# NIC
resource "azurerm_network_interface" "nic" {
  name                = "vm--nic"
  location            = local.primary_location
  resource_group_name = local.primary_rg

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet["prod-vnet-app-subnet"].id
    private_ip_address_allocation = "Dynamic"
  }
}
# =====================================================
# Bastion Public IPs
# =====================================================
resource "azurerm_public_ip" "bastion_pip" {
  name                = "pip-bastion-eastus"
  location            = local.primary_location
  resource_group_name = local.primary_rg
  allocation_method   = "Static"
  sku                 = "Standard"
}


# =====================================================
# Bastion Hosts
# =====================================================
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-eastus"
  location            = local.primary_location
  resource_group_name = local.primary_rg

  ip_configuration {
    name                 = "bastion-ipcfg"
    subnet_id            = azurerm_subnet.subnet["prod-vnet-AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}