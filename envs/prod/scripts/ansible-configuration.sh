#!/bin/bash
set -euo pipefail


echo "Initializing Terraform providers..."

terraform -chdir=../terraform init -upgrade

echo "Fetching Terraform outputs..."

VM_IP=$(terraform -chdir=../terraform output -raw vm_pip)
COSMOS_ENDPOINT=$(terraform -chdir=../terraform output -raw cosmosdb_uri)
COSMOS_KEY=$(terraform -chdir=../terraform output -raw cosmos_key)

echo "Updating Ansible inventory..."

cat > ../ansible/inventory.ini <<EOT
[cosmos_vm]
$VM_IP ansible_user=azureuser ansible_ssh_private_key_file=/home/hardeymolhar/.ssh/prod/prod-key
EOT

echo "Running Ansible playbook..."
ANSIBLE_CONFIG=../ansible/ansible.cfg \
ansible-playbook \
../ansible/ansible-playbook-bkp.yml \
--extra-vars "cosmos_endpoint=$COSMOS_ENDPOINT cosmos_key=$COSMOS_KEY"

echo "Pipeline completed successfully."

