# VNet + Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "dev-vnet"
  location            = var.location
  resource_group_name = var.rg[0]
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "dev-subnet"
  resource_group_name  = var.rg[0]
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}
