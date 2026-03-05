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
  default = ["rg_sb_eastus_308450_1_177273186276",
    "rg_sb_westus_308450_2_177273186467",
  "rg_sb_centralindia_308450_3_177273186523"]
}

variable "location" {
  type        = list(string)
  description = "Azure region for all resources."
  default     = ["eastus", "westus", "centralindia"]
}



variable "cosmosdb_structure" {
  type = map(object({
    containers = map(object({
      partition_key = string
    }))
    throughput = number
  }))
}


variable "network_structure" {
  type = map(object({
    address_space = list(string)

    subnets = map(object({
      address_prefix = list(string)
    }))
  }))
}


