

data "azurerm_client_config" "current" {}

data "http" "client_ip" {
  url = "https://api.ipify.org"
}



#======
#SAS
#======

data "azurerm_storage_account_sas" "script_sas" {
  connection_string = azurerm_storage_account.storage_accounts["multimedia"].primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "2h")

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
    filter  = false
    tag     = false
  }
}


data "azurerm_cosmosdb_account" "cosmos" {
  name                = azurerm_cosmosdb_account.cosmos.name
  resource_group_name = local.primary_rg
}
