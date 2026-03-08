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

VM_IP=$(terraform output -raw vm_public_ip)
COSMOS_ENDPOINT=$(terraform output -raw cosmos_endpoint)
COSMOS_KEY=$(terraform output -raw cosmos_key)

echo "Updating Ansible inventory..."

cat > ansible/inventory.ini <<EOF
[cosmos_vm]
$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=terraform/keys/d3v-u6untu-01_key
EOF


echo "Running Ansible configuration..."

ansible-playbook ansible/playbooks/install-nginx.yml \
  --extra-vars "cosmos_endpoint=$COSMOS_ENDPOINT cosmos_key=$COSMOS_KEY"

echo "Pipeline completed successfully."