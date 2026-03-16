variable "subscription_id" {
  description = "ID of the subscription"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "azureuser"
}


variable "rg" {
  type        = list(string)
  description = "Resource group name"
}

variable "location" {
  type        = list(string)
  description = "Azure region for all resources."
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



variable "admin_username" {
  description = "VM Admin username"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "VM Admin username"
  type        = string
}



variable "vm_name" {
  type    = string
  default = "d3v-u6untu-01"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "availability_zone" {
  type        = string
  default     = "3"
  description = "Availability zone (use \"1\", \"2\" or \"3\")"
}

variable "ssh_key_name" {
  type    = string
  default = "d3v-u6untu-01_key"
}



variable "image_publisher" {
  type    = string
  default = "RedHat"
}

variable "image_offer" {
  type    = string
  default = "RHEL"
}

variable "image_sku" {
  type    = string
  default = "9-lvm-gen2"
}


variable "image_version" {
  type    = string
  default = "latest"
}

