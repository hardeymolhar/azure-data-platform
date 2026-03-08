
# ===============
# Storage Account
# ===============
resource "azurerm_storage_account" "storage" {
  name                     = "prodstorage21151"
  resource_group_name      = local.primary_rg
  location                 = local.primary_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
  https_traffic_only_enabled    = true
}


resource "azurerm_storage_container" "account" {
  name                  = "account"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"


}

resource "azurerm_storage_blob" "init_script" {
  name                   = "cloud-init.yaml"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.account.name
  type                   = "Block"
  source                 = "${path.module}/config-files/cloud-init.yaml"

  depends_on = [
    azurerm_storage_container.account
  ]
}

resource "azurerm_storage_blob" "init_script_env" {
  name                   = "provision-cosmos-sdk-vm.sh"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.account.name
  type                   = "Block"
  source                 = "${path.module}/config-files/provision-cosmos-sdk-vm.sh"

  depends_on = [
    azurerm_storage_blob.init_script
  ]
}

