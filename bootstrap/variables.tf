variable "rg" {
  type        = list(string)
  description = "Resource group name"
  default = ["rg_sb_eastus_308450_1_177357878126",
    "rg_sb_westus_308450_2_177357878342",
  "rg_sb_centralindia_308450_3_177357878546"]
}

variable "location" {
  type        = list(string)
  description = "Azure region for all resources."
  default     = ["eastus", "westus", "centralindia"]
}


variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}