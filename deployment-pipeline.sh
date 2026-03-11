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
  -parallelism=50 \
  -out=tfplan

echo "Applying Terraform plan..."
terraform -chdir=terraform apply -auto-approve tfplan

wsl -d ubuntu ./ansible-configuration.sh
