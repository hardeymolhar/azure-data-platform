output "cosmosdb_uri" {
  description = "Cosmos DB endpoint URI"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}

