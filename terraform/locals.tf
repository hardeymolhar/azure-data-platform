locals {
  containers = flatten([
    for db_name, db in var.cosmosdb_structure : [
      for container_name, container in db.containers : {
        db_name        = db_name
        container_name = container_name
        partition_key  = container.partition_key
        throughput     = container.throughput
      }
    ]
  ])
}




locals {
  subnet_map = merge([
    for vnet_name, vnet in var.network_structure : {
      for subnet_name, subnet_obj in vnet.subnets :
      "${vnet_name}-${subnet_name}" => {
        vnet_name      = vnet_name
        subnet_name    = subnet_name
        address_prefix = subnet_obj.address_prefix
      }
    }
  ]...)
}




locals {
  primary_location   = var.location[0]
  secondary_location = length(var.location) > 1 ? var.location[1] : null

  primary_rg   = var.rg[0]
  secondary_rg = length(var.rg) > 1 ? var.rg[1] : null
  tertiary_rg  = length(var.rg) > 2 ? var.rg[2] : null
}