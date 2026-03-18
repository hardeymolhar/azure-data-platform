/* Use this if you want total control over your backend */
terraform {
  backend "azurerm" {
    resource_group_name  = "rg_sb_westus_308450_2_177384235110"
    storage_account_name = "tfstate21151"
    container_name       = "terraform-state-files"
  }
}
/*
Initially used a static backend configuration, but this approach does not scale
for multi-environment deployments.

Backend configuration is evaluated during `terraform init`, before variables
are available, which makes dynamic state separation impossible when hardcoded.

To address this, the backend block was simplified and configuration is now
injected at runtime via the deployment pipeline.

This enables:
- Environment-specific state isolation (dev, prod, etc.)
- Reusable and environment-agnostic Terraform code
- Cleaner separation between infrastructure definition and deployment logic

Backend configuration is now handled during initialization using
`-backend-config` in the deployment script.


terraform {
  backend "azurerm" {
    resource_group_name  = "rg_sb_westus_308450_2_177374335056"
    storage_account_name = "tfstate21151"
    container_name       = "terraform-state-files"
  }
}

*/

