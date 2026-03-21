resource "azurerm_log_analytics_workspace" "law" {
  name                = "cosmos-law"
  location            = local.primary_location
  resource_group_name = local.primary_rg

  sku               = "PerGB2018"
  retention_in_days = 30
}



resource "azurerm_monitor_diagnostic_setting" "cosmos_logs" {
  name                       = "cosmos-diagnostics"
  target_resource_id         = azurerm_cosmosdb_account.cosmos.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "DataPlaneRequests"
  }

  enabled_log {
    category = "QueryRuntimeStatistics"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}