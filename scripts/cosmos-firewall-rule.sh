#!/bin/bash
set -euo pipefail

RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
ACCOUNT_NAME="cosmosdb1725234"


az cosmosdb update \
  --name cosmosdb1725234 \
  --resource-group $RESOURCE_GROUP \
  --ip-range-filter $CLIENT_IP