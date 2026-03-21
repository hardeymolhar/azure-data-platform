#!/bin/bash
set -euo pipefail

RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
ACCOUNT_NAME="cosmosdb1725234"

COSMOS_KEY=$(az cosmosdb keys list \
  --name "$ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --type keys \
  --query "primaryMasterKey" \
  --output tsv) 

COSMOS_ENDPOINT=$(az cosmosdb show \
  --name "$ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "documentEndpoint" \
  --output tsv)

echo "Cosmos DB Endpoint: $COSMOS_ENDPOINT"
echo "Cosmos DB Primary Key: $COSMOS_KEY"