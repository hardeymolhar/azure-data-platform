
# ===============
# Storage Account
# ===============


# Use a dynamic for_each so any file dropped into the scripts/ folder is automatically
# uploaded as a blob. This is more maintainable than hardcoding each blob resource.
# The older approach (below, currently commented out) required defining each blob
# explicitly and updating the Terraform configuration whenever a new script was added.
/*
resource "azurerm_storage_account" "storage_accounts" {
  for_each = local.storage_accounts

  name                = each.value.name
  resource_group_name = local.primary_rg
  location            = local.primary_location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  account_kind    = "StorageV2"
  min_tls_version = "TLS1_2"

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




resource "azurerm_storage_container" "containers" {
  for_each = azurerm_storage_account.storage_accounts

  name                  = each.key
  storage_account_name  = each.value.name
  container_access_type = "private"
}



/*resource "azurerm_storage_blob" "scripts" {
  for_each = fileset("${path.module}/scripts", "*")

  name                   = each.value
  storage_account_name   = azurerm_storage_account.storage_accounts["scripts"].name
  storage_container_name = azurerm_storage_container.containers["scripts"].name
  type                   = "Block"

  source = "${path.module}/scripts/${each.value}"
} */



#resource "azurerm_storage_blob" "init_script" {
#  name                   = "cloud-init.yaml"
#  storage_account_name   = azurerm_storage_account.storage.name
#  storage_container_name = azurerm_storage_container.account.name
#  type                   = "Block"
#  source                 = "${path.module}/scripts/cloud-init.yml"
#
#  depends_on = [
#    azurerm_storage_container.account
#  ]
#}

#resource "azurerm_storage_blob" "init_script_env" {
#  name                   = "dotnet-install.sh"
#  storage_account_name   = azurerm_storage_account.storage.name
# storage_container_name = azurerm_storage_container.account.name
# type                   = "Block"
# source                 = "${path.module}/scripts/bootstrapped-dotnet-installation.sh"

#  depends_on = [
#    azurerm_storage_blob.init_script
#  ]
# }

