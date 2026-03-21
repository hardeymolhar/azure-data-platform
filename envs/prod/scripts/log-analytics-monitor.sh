#!/bin/bash
set -euo pipefail


echo "Fetching Log Analytics workspace ID..."
workspace_id=$(az monitor log-analytics workspace list \
--resource-group "$(az group list --query "[0].name" -o tsv)" \
--query "[0].customerId" -o tsv)

echo "Fetched Log Analytics Workspace ID"

echo "Querying Log Analytics for recent logs..."
az monitor log-analytics query \
--workspace "$workspace_id" \
--analytics-query '
AzureDiagnostics
| where Category contains "DataPlane"
| where isnotempty(databaseName_s)
| where isnotempty(collectionName_s)
| summarize totalRU=sum(todouble(requestCharge_s))
  by bin(TimeGenerated,5m), databaseName_s, collectionName_s
| order by TimeGenerated desc
' \
-o jsonc