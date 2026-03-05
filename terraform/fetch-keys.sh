RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
ACCOUNT_NAME="cosmosdb1725234"

az cosmosdb keys list \
  --name "$ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --type keys \
  --query "primaryMasterKey" \
  --output tsv

