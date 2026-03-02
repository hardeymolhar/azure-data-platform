# Architecture Overview

## Infrastructure Layer
Provisioned using Terraform:
- Azure Cosmos DB (SQL API)
- Database: mycosmosdb
- Container: items
- Partition key: /categoryId
- Throughput: 400 RU/s

## Application Layer
.NET 8 SDK:
- Secure environment-based authentication
- Transactional batch operations
- Single-partition atomic writes