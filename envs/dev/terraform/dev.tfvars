subscription_id = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"

admin_password = "r3P1iKa5x_123"

rg = ["rg_sb_centralindia_308450_3_177410036452",
  "rg_sb_westus_308450_2_177410036326",
"rg_sb_eastus_308450_1_177410036263"]

location = [
  "centralindia",
  "westus",
  "eastus"
]

cosmosdb_structure = {
  db1 = {
    throughput = 400

    containers = {
      orders    = { partition_key = "/orderId" }
      customers = { partition_key = "/customerId" }
      products  = { partition_key = "/productId" }
      inventory = { partition_key = "/sku" }
      auditlogs = { partition_key = "/logId" }
    }


  }

  db2 = {
    throughput = 400

    containers = {
      sessions  = { partition_key = "/sessionId" }
      payments  = { partition_key = "/paymentId" }
      invoices  = { partition_key = "/invoiceId" }
      shipments = { partition_key = "/shipmentId" }
      returns   = { partition_key = "/returnId" }
    }


  }

  db3 = {
    throughput = 400

    containers = {
      users       = { partition_key = "/userId" }
      roles       = { partition_key = "/roleId" }
      permissions = { partition_key = "/permissionId" }
      profiles    = { partition_key = "/profileId" }
      activity    = { partition_key = "/activityId" }
    }

  }

  db4 = {
    throughput = 400

    containers = {
      tenants  = { partition_key = "/tenantId" }
      plans    = { partition_key = "/planId" }
      features = { partition_key = "/featureId" }
      usage    = { partition_key = "/usageId" }
      billing  = { partition_key = "/billingId" }
    }

  }

  db5 = {
    throughput = 400

    containers = {
      notifications = { partition_key = "/notificationId" }
      messages      = { partition_key = "/messageId" }
      chats         = { partition_key = "/chatId" }
      attachments   = { partition_key = "/attachmentId" }
      settings      = { partition_key = "/settingId" }
    }
  }
}




network_structure = {

  dev-vnet = {
    address_space = ["10.1.0.0/16"]

    subnets = {
      app-subnet = {
        address_prefix = ["10.1.1.0/24"]
      }

      db-subnet = {
        address_prefix = ["10.1.2.0/24"]
      }

      pe-subnet = {
        address_prefix = ["10.1.3.0/24"]
      }

      AzureBastionSubnet = {
        address_prefix = ["10.1.4.0/26"]
      }
    }
  }
}