# Phase 4 — Cosmos DB Indexing Strategy & Terraform Module Refactoring
 

## Architecture Diagram

![Cosmos DB SDK Architecture](images/Phase-3-Architecture.png)



## Overview
By default, Azure Cosmos DB automatically indexes all properties of all items in your container without requiring you to specify any schema or create secondary indexes. 
Indexing policy can be customized to include or exclude specific paths to optimize for the read and write workloads of your application. 
Optimizing indexing policy can reduce costs and improve performance for specific types of operations. 


## Objective

```mermaid
flowchart TD

A[Phase 4: Index Optimization]
B[Optimize Index Paths]
C[Exclude Unnecessary Fields]
D[Better Query Efficiency]
E[Lower RU Consumption]

A --> B
A --> C
B --> D
C --> E
```

## Index Optimization Validation Workflow

```mermaid
flowchart TD

subgraph Optimization
A[Index Policy Adjustment]
end

subgraph Validation
B[Manual Testing]
C[RU & Query Performance Evaluation]
end

subgraph Deployment
D[Automated Deployment via Ansible]
end

A --> B
B --> C
C --> D
```

## Project Progression

```
-----------------------------------------------------------------------
Phase                               Focus
-----------------------------------------------------------------------
Phase 1                             Establish Cosmos DB connectivity
                                       | .NET SDK |

Phase 2                             Implement high-efficiency ingestion 
                                       | Transactional Batch |

Phase 3                             Automate infrastructure and deployment
                                       | Terraform, Ansible |

Phase 4                             Optimize CosmosDB index policy
                                       | Cosmos DB Indexing |
-----------------------------------------------------------------------
```








LEGACY IMPLEMENTATION (INITIAL DESIGN)

Originally, a single storage account was provisioned primarily to store
automation artifacts such as bootstrap scripts and configuration files.

At this stage of the project, Terraform state was still stored locally.
This approach worked for initial experimentation but presented several
limitations:

- State files were stored locally on the developer machine
- No centralized state management
- Risk of state drift or corruption
- Not suitable for collaborative workflows

As the infrastructure evolved and reproducibility became more important,
the design was upgraded to use a **remote Terraform backend stored in
Azure Blob Storage**. This allowed Terraform state to be centrally managed
and automatically locked during operations.

The implementation below is preserved for documentation purposes to
illustrate the early design phase of the project.

Replaced by:
Terraform Remote State Backend using Azure Storage.