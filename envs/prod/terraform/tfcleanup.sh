#!/usr/bin/env bash
set -euo pipefail

# Resolve cleanup directory
CLEANUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$CLEANUP_DIR"

echo "Running cleanup from project root: $CLEANUP_DIR"

# Remove Terraform artifacts across project
find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "terraform.tfstate" -delete 2>/dev/null || true
find . -type f -name "terraform.tfstate.backup" -delete 2>/dev/null || true
find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
find . -type f -name "tfplan" -delete 2>/dev/null || true

echo "Cleanup complete."