#!/usr/bin/env bash
set -euo pipefail

# Set environment (default = dev)
ENV=${1:-dev}

echo -e "\e[33mEnvironment: $ENV\e[0m"

# ----------------------------------------
# ENVIRONMENT STRATEGY
# ----------------------------------------

: '

NOTE : You can only pick one of the below strategies for handling multiple environments. 
I have implemented the dynamic backend strategy in the init script but I have also added the workspace strategy as a comment for reference.

Option 1 — Dynamic Backend (Recommended for CI/CD)

Use when:
- You want explicit control
- Multi-environment deployments
- Production pipelines

Example:

terraform init \
  -backend-config="key=${ENV}.terraform.tfstate"
'

: '
Option 2 — Workspaces

Use when:
- Backend is static
- Simpler setups
- Environments are similar

Example:

terraform workspace select $ENV 2>/dev/null || terraform workspace new $ENV
'

# ----------------------------------------
# TERRAFORM EXECUTION
# ----------------------------------------


terraform -chdir=../terraform init -migrate-state \
  -backend-config="key=${ENV}.terraform.tfstate"

echo -e "\e[33mFormatting Terraform files...\e[0m"
terraform -chdir=../terraform fmt -recursive

echo -e "\e[33mValidating Terraform configuration...\e[0m"
terraform -chdir=../terraform validate

echo -e "\e[33mCreating execution plan...\e[0m"
terraform -chdir=../terraform plan \
  -var-file="${ENV}.tfvars" \
  -parallelism=10 \
  -out=tfplan

echo -e "\e[33mApplying Terraform plan...\e[0m"
terraform -chdir=../terraform apply tfplan

# ----------------------------------------
# ANSIBLE
# ----------------------------------------

echo -e "\e[33mRunning Ansible configuration...\e[0m"
MSYS_NO_PATHCONV=1 wsl -d ubuntu /mnt/c/Users/DELL/azure-data-platform/scripts/ansible-configuration.sh