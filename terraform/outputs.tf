output "cosmosdb_uri" {
  description = "Cosmos DB endpoint URI"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}


output "vm_pip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

