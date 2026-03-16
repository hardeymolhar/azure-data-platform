/*
 * This file defines the Terraform backend configuration for storing the state in Azure Blob Storage.
 * It specifies the resource group, storage account, container, and key for the Terraform state file.
 */
terraform {
  backend "azurerm" {
    resource_group_name  = "rg_sb_westus_308450_2_177366024617"
    storage_account_name = "tfstate21151"
    container_name       = "tfstate"
    key                  = "azure-data-platform.tfstate"
  }
}
