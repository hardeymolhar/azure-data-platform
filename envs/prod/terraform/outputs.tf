output "cosmosdb_uri" {
  description = "Cosmos DB endpoint URI"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}


output "vm_pip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "client_ip" {
  description = "Client IP address (used for NSG rules and Cosmos DB firewall)"
  value       = local.client_ip
}

output "cosmos_key" {
  description = "Primary key for Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.primary_key
  sensitive   = true
}


output "vm_name" {
  description = "Name of the provisioned VM"
  value       = azurerm_linux_virtual_machine.vm.name
}

