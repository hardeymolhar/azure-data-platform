# generate an RSA keypair locally (sensitive)
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



# optionally persist private key locally (secure the filesystem and terraform state)
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/keys/${var.ssh_key_name}"
  file_permission = "0600"
}



# Linux VM (Gen2, zone aware)
resource "azurerm_linux_virtual_machine" "vm" {


  name                = var.vm_name
  resource_group_name = local.primary_rg
  location            = local.primary_location
  size                = var.vm_size
  admin_username      = var.admin_username

  custom_data = base64encode(templatefile("${path.module}/config-files/cloud-init.yaml", {
    storage_account = azurerm_storage_account.storage.name
    sas_token       = data.azurerm_storage_account_sas.script_sas.sas
    cosmos_endpoint = data.azurerm_cosmosdb_account.cosmos.endpoint
    cosmos_key      = azurerm_cosmosdb_account.cosmos.primary_key
  }))


  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.ssh_key.public_key_openssh
  }
  disable_password_authentication = true


  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  zone = var.availability_zone

  identity {
    type = "SystemAssigned"
  }


  # Trusted Launch support: secure boot and vTPM
  # provider >= where secure_boot_enabled & vtpm_enabled are supported
  secure_boot_enabled = true
  vtpm_enabled        = true


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_ZRS"
    disk_size_gb         = 128
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  # Optional: cloud-init for initial hardening (uncomment and supply templatefile)
  # custom_data = base64encode(file("${path.module}/cloud-init-sh.yaml"))

  # Tags and identity as required
  tags = {
    environment = "production"
    owner       = "dbadmin"
  }


}
