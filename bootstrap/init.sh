#!/usr/bin/env bash
set -euo pipefail

# Resolve bootstrap directory
INIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


cd "$INIT_DIR"


echo -e "\e[33mInitializing Terraform without backend...\e[0m"
terraform init -backend=false

echo -e "\e[33mFormatting Terraform configuration files...\e[0m"
terraform fmt -recursive

echo -e "\e[33mValidating Configuration...\e[0m"
terraform validate

echo -e "\e[33mPlanning Terraform deployment...\e[0m"
terraform plan -out=tfplan -var-file=variables.tfvars --parallelism=3

echo -e "\e[33mApplying Terraform configuration to set up backend storage...\e[0m"
terraform apply tfplan 

echo -e "\e[32mStorage account for Terraform state has been set up successfully.\e[0m"