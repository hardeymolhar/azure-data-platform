#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Terraform..."
terraform init --upgrade

echo "Formatting Terraform files..."
terraform fmt -recursive

echo "Validating Terraform configuration..."
terraform validate

echo "Creating execution plan..."
terraform plan \
  -var-file="variables.tfvars" \
  -parallelism=30 \
  -out=tfplan

echo "Applying Terraform plan..."
terraform apply -auto-approve tfplan

echo "Fetching Terraform outputs..."

VM_IP=$(terraform output -raw vm_pip)
COSMOS_ENDPOINT=$(terraform output -raw cosmosdb_uri)
COSMOS_KEY=$(terraform output -raw cosmos_key)

echo "Copying SSH key for Ansible access..."
cp /mnt/c/Users/DELL/azure-data-platform/terraform/keys/d3v-u6untu-01_key ~/.ssh/

echo "Setting permissions for SSH key..."
chmod 600 ~/.ssh/d3v-u6untu-01_key

echo "Updating Ansible inventory..."

cat > ../../ansible/inventory.ini <<EOF
[cosmos_vm]
$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=terraform/keys/d3v-u6untu-01_key
EOF


echo "Running Ansible configuration..."

ansible-playbook ansible/playbooks/install-nginx.yml \
  --extra-vars "cosmos_endpoint=$COSMOS_ENDPOINT cosmos_key=$COSMOS_KEY"

echo "Pipeline completed successfully."