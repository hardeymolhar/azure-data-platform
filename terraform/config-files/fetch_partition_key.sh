#!/bin/bash

RESOURCE_GROUP="rg_sb_eastus_308450_1_177256592430"
ACCOUNT_NAME="cosmosdb1725234"

echo "Auditing Cosmos DB Partition Keys"
echo "=================================="

az cosmosdb sql database list \
  --resource-group "$RESOURCE_GROUP" \
  --account-name "$ACCOUNT_NAME" \
  --query "[].name" -o tsv \
| tr -d '\r' \
| while IFS= read -r db; do

  echo ""
  echo "Database: $db"
  echo "------------------"

  az cosmosdb sql container list \
    --resource-group "$RESOURCE_GROUP" \
    --account-name "$ACCOUNT_NAME" \
    --database-name "$db" \
    --query "[].name" -o tsv \
  | tr -d '\r' \
  | while IFS= read -r container; do

    pk=$(az cosmosdb sql container show \
      --resource-group "$RESOURCE_GROUP" \
      --account-name "$ACCOUNT_NAME" \
      --database-name "$db" \
      --name "$container" \
      --query "resource.partitionKey.paths" -o tsv)

    echo "Container: $container"
    echo "Partition Key: $pk"
  done
done