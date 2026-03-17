#!/usr/bin/env bash
set -euo pipefail

echo -e "\e[33mInitializing Terraform with backend...\e[0m"
terraform -chdir=../terraform init --upgrade

echo -e "\e[33mFormatting Terraform files...\e[0m"
terraform -chdir=../terraform fmt -recursive

echo -e "\e[33mValidating Terraform configuration...\e[0m"
terraform -chdir=../terraform validate

echo -e "\e[33mCreating execution plan...\e[0m"
terraform -chdir=../terraform plan \
  -var-file="variables.tfvars" \
  -parallelism=10 \
  -out=tfplan

echo -e "\e[33mApplying Terraform plan...\e[0m"
terraform -chdir=../terraform apply -auto-approve tfplan


echo -e "\e[33mRunning Ansible configuration...\e[0m"
MSYS_NO_PATHCONV=1 wsl -d ubuntu /mnt/c/Users/DELL/azure-data-platform/scripts/ansible-configuration.sh


