#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Terraform..."
terraform -chdir=../terraform init --upgrade

echo "Formatting Terraform files..."
terraform -chdir=../terraform fmt -recursive

echo "Validating Terraform configuration..."
terraform -chdir=../terraform validate

echo "Creating execution plan..."
terraform -chdir=../terraform plan \
  -var-file="variables.tfvars" \
  -parallelism=10 \
  -out=tfplan

echo "Applying Terraform plan..."
terraform -chdir=../terraform apply -auto-approve tfplan


echo "Running Ansible configuration..."
MSYS_NO_PATHCONV=1 wsl -d ubuntu /mnt/c/Users/DELL/azure-data-platform/scripts/ansible-configuration.sh


#An alternative to the above command, in case of any issues with path conversion:
#wsl -d ubuntu bash -c "/mnt/c/Users/DELL/azure-data-platform/scripts/ansible-configuration.sh"
