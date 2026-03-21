

## Azure SQL Server
#resource "azurerm_mssql_server" "sql" {
#  name                         = "sqlserver123455667"
#  resource_group_name          = var.rg[0] # using the first resource group from the list
#  location                     = local.primary_location
#  version                      = "12.0"
#  administrator_login          = "sqladminuser"
#  administrator_login_password = "ComplexP@ssw0rd!"
#}
#
## Azure SQL Database
#resource "azurerm_mssql_database" "db" {
#  name           = "AZ500LabDb"
#  server_id      = azurerm_mssql_server.sql.id
#  collation      = "SQL_Latin1_General_CP1_CI_AS"
#  max_size_gb    = 2
#  sku_name       = "Basic"
#  sample_name    = "AdventureWorksLT"
#  zone_redundant = false
#}
#
#resource "azurerm_mssql_firewall_rule" "sql_allow_client" {
#  name       = "AllowClientIP"
#  server_id  = azurerm_mssql_server.sql.id
#  start_ip_address = var.client_ip
#  end_ip_address   = var.client_ip
#}
#
## Optional: allow all Azure services
#resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
#  name       = "AllowAzureServices"
#  server_id  = azurerm_mssql_server.sql.id
#  start_ip_address = "0.0.0.0"
#  end_ip_address   = "0.0.0.0"
#}
#
## Azure Database for MySQL Server
#resource "azurerm_mysql_flexible_server" "mysql" {
#  name                = "mysqlsrv123"
#  location            = local.primary_location
#  resource_group_name = var.rg[0]
#
#  administrator_login          = var.db_username
#  administrator_password = var.db_password
#
#  version = "8.0.21"
#  sku_name = "B_Standard_B1ms"  # Example SKU, adjust as needed
#  zone     = "1"
#
#  lifecycle {
#    ignore_changes = [
#     zone 
#    ]
#  }
#
#}
#
#resource "azurerm_mysql_flexible_database" "appdb" {
#  name                = "appdb"
#  resource_group_name = var.rg[0]
#  server_name         = azurerm_mysql_flexible_server.mysql.name
#
#  charset  = "utf8"
#  collation = "utf8_general_ci"
#}
#
#resource "azurerm_mysql_flexible_server_firewall_rule" "rule1" {
#  name                = "AllowClientIP"
#  resource_group_name = var.rg[0]
#  server_name         = azurerm_mysql_flexible_server.mysql.name
#
#  start_ip_address    = var.client_ip
#  end_ip_address      = var.client_ip
#}
#
## Optional: allow all Azure services
#resource "azurerm_mysql_flexible_server_firewall_rule" "allow_azure_services" {
#  name                = "AllowAzure"
#  resource_group_name = var.rg[0]
#  server_name         = azurerm_mysql_flexible_server.mysql.name
#
#  # Note: Azure’s MySQL firewall treats 0.0.0.0–0.0.0.0 as allow-Azure
#  start_ip_address    = "0.0.0.0"
#  end_ip_address      = "0.0.0.0"
#}
#


resource "random_string" "suffix" {
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}


# Azure Cosmos DB Account
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "cosmosdb${random_string.suffix.result}"
  location            = local.primary_location
  resource_group_name = local.primary_rg
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  local_authentication_disabled      = false
  access_key_metadata_writes_enabled = false

  ip_range_filter = [
    "${local.client_ip}/32"
  ]

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = local.primary_location
    failover_priority = 0
  }
}


resource "azurerm_cosmosdb_sql_database" "databases" {
  for_each = var.cosmosdb_structure

  name                = each.key
  resource_group_name = local.primary_rg
  account_name        = azurerm_cosmosdb_account.cosmos.name
  throughput          = each.value.throughput

}

resource "azurerm_cosmosdb_sql_container" "containers" {
  for_each = {
    for c in local.containers :
    "${c.db_name}-${c.container_name}" => c
  }

  name                = each.value.container_name
  resource_group_name = local.primary_rg
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.databases[each.value.db_name].name

  partition_key_paths = [each.value.partition_key]
  partition_key_kind  = "Hash"

}


# Cosmos DB SQL Database
#resource "azurerm_cosmosdb_sql_database" "cosmos_db" {
#  name                = "mycosmosdb"
#  resource_group_name = var.rg[0]
#  account_name        = azurerm_cosmosdb_account.cosmos.name
#}

## Cosmos DB SQL Container
#resource "azurerm_cosmosdb_sql_container" "cosmos_container" {
#  name                = "items"
#  resource_group_name = var.rg[0]
#  account_name        = azurerm_cosmosdb_account.cosmos.name
#  database_name       = azurerm_cosmosdb_sql_database.cosmos_db.name
#  partition_key_paths  = ["/categoryId"]
#}
