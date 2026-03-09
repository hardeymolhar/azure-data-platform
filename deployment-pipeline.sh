#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Terraform..."
terraform -chdir=terraform init --upgrade

echo "Formatting Terraform files..."
terraform -chdir=terraform fmt -recursive

echo "Validating Terraform configuration..."
terraform -chdir=terraform validate

echo "Creating execution plan..."
terraform -chdir=terraform plan \
  -var-file="variables.tfvars" \
  -parallelism=30 \
  -out=tfplan

echo "Applying Terraform plan..."
terraform -chdir=terraform apply -auto-approve tfplan

echo "Fetching Terraform outputs..."

VM_IP=$(terraform -chdir=terraform output -raw vm_pip)
COSMOS_ENDPOINT=$(terraform -chdir=terraform output -raw cosmosdb_uri)
COSMOS_KEY=$(terraform -chdir=terraform output -raw cosmos_key)

echo "Updating Ansible inventory..."
cat > ansible/inventory.ini <<EOF
[cosmos_vm]
$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=/home/hardeymolhar/.ssh/d3v-u6untu-01_key
EOF

echo "Running Ansible playbook..."

ansible-playbook ansible/ansible-playbook.yml \
--extra-vars "cosmos_endpoint=$COSMOS_ENDPOINT cosmos_key=$COSMOS_KEY"

echo "Pipeline completed successfully."