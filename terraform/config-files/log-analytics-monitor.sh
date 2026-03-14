#!/bin/bash
set -euo pipefail

#First you query the logs with the command "AzureDiagnostics | take 10"

echo "Fetching Log Analytics workspace ID..."
workspace_id=$(az monitor log-analytics workspace list \
--query "[0].customerId" -o tsv)

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
'