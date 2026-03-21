RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
ACCOUNT_NAME="cosmosdb1725234"

az cosmosdb sql container update \
  --account-name $ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --database-name db1 \
  --name auditlogs \
  --idx @index-policy.json


