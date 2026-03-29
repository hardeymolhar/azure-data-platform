locals {
  containers = flatten([
    for db_name, db in var.cosmosdb_structure : [
      for container_name, container in db.containers : {
        db_name        = db_name
        container_name = container_name
        partition_key  = container.partition_key
        throughput     = db.throughput
      }
    ]
  ])
}

/*Introduced this local as part of attempt in understanding workspaces*/
locals {
  environment = terraform.workspace
}


/*
locals {
  storage_accounts = {
    multimedia = {
      name = "multimedia12151"
    }

    tfstate = {
      name = "tfstate21151"
    }
  }
}
*/

locals {
  client_ip = chomp(data.http.client_ip.response_body)
}


locals {

  subnets = flatten([
    for vnet_name, vnet in var.network_structure : [
      for subnet_name, subnet_obj in vnet.subnets : {
        vnet_name   = vnet_name
        subnet_name = subnet_name
        prefix      = subnet_obj.address_prefix
      }
    ]
  ])

  subnet_map = {
    for subnet in local.subnets :
    "${subnet.vnet_name}-${subnet.subnet_name}" => subnet
  }
}




locals {
  primary_location   = var.location[0]
  secondary_location = length(var.location) > 1 ? var.location[1] : null

  primary_rg   = var.rg[0]
  secondary_rg = length(var.rg) > 1 ? var.rg[1] : null
  tertiary_rg  = length(var.rg) > 2 ? var.rg[2] : null
}