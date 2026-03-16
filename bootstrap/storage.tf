resource "azurerm_storage_account" "tfstate" {
  name                = "tfstate21151"
  resource_group_name = "rg_sb_westus_308450_2_177366024617"
  location            = "westus"

  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false


  network_rules {

    default_action = "Deny"

    ip_rules = [
      "${local.client_ip}/30"
    ]

    bypass = [
      "AzureServices"
    ]
  }
}


resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}