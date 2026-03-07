resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "pev-prod-cosmos"
  resource_group_name = local.primary_rg
  location            = local.primary_location
  subnet_id           = azurerm_subnet.subnet["prod-vnet-pe-subnet"].id

  private_service_connection {
    name                           = "psc-cosmos"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    subresource_names              = ["Sql"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "cosmos-dns-group"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.cosmos.id
    ]
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.cosmos_link
  ]
}


resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = local.primary_rg
}


resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_link" {
  name                  = "cosmos-dns-link"
  resource_group_name   = local.primary_rg
  private_dns_zone_name = azurerm_private_dns_zone.cosmos.name
  virtual_network_id    = azurerm_virtual_network.vnet["prod-vnet"].id
}




#===============
# INTERNAL LOCAL
#===============


resource "azurerm_private_dns_zone" "vm_dns" {
  name                = "internal.local"
  resource_group_name = local.primary_rg
}


resource "azurerm_private_dns_zone_virtual_network_link" "vm_dns_link" {
  name                  = "vm-dns-link"
  resource_group_name   = local.primary_rg
  private_dns_zone_name = azurerm_private_dns_zone.vm_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet["prod-vnet"].id

  registration_enabled = true
}
