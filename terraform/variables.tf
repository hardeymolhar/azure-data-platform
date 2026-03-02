variable "subscription_id" {
  description = "ID of the subscription"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "azureuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
}

variable "client_ip" {
  description = "Client IP address to allow access"
  type        = string
}



variable "rg" {
  type        = list(string)
  description = "Resource group name"
  default     = ["rg_sb_eastus_308450_1_17723966358",
                 "rg_sb_westus_308450_2_177239663779",
                 "rg_sb_centralindia_308450_3_177239663992"]
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "centralindia"
}