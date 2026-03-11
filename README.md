
# Azure Cosmos DB Data Platform

This project explores how to build an automated data ingestion
platform for Azure Cosmos DB while maintaining fully reproducible
infrastructure and efficient batch operations.

The goal was to answer a practical engineering question:

```bash
 🤔 How might we efficiently ingest large volumes of data into Cosmos DB 
 while keeping infrastructure fully reproducible and automated?
```

To explore this, the platform evolves across three phases:
1. Validating Cosmos DB SDK connectivity
2. Designing a high-efficiency batch ingestion strategy
3. Automating the entire infrastructure and deployment pipeline
---







# System Architecture

```mermaid

flowchart TD

subgraph Cloud Platform
A[Microsoft Azure]
end

subgraph Infrastructure
B[Terraform<br>Infrastructure as Code]
end

subgraph Networking
C[Virtual Network]
D[Network Security Groups]
E[Service Endpoints]
end

subgraph Compute
F[Azure Virtual Machine]
end

subgraph Configuration
G[Ansible<br>Configuration Management]
end

subgraph Application
H[.NET SDK Application]
end

subgraph Database
I[Azure Cosmos DB]
end

A --> B
B --> C
C --> D
C --> E
C --> F

F --> G
G --> H
H --> I

```

## Key Engineering Decisions

- Used TransactionalBatch API to reduce Cosmos DB network overhead
- Implemented Terraform for reproducible infrastructure
- Adopted Ansible for server configuration instead of ad-hoc scripts
- Switched from Private Endpoints to Service Endpoints due to RBAC constraints
---

# Project Phases

| Phase | Description |
|-----|-----|
| Phase 1 | Cosmos DB SDK connectivity validation |
| Phase 2 | Transactional batch ingestion engine |
| Phase 3 | Automated infrastructure deployment and orchestration |

Detailed documentation:

- [Phase 1 — SDK Connectivity](docs/phase-1-sdk-connection.md)
- [Phase 2 — Transactional Batch Operations](docs/phase-2-transactional-batch.md)
- [Phase 3 — Infrastructure Automation](docs/phase-3-infra-automation.md)

---

# Infrastructure Automation

Infrastructure resources are provisioned using Terraform.

<p align="center">
<img src="docs/images/terraform-graph.svg" width="900">
</p>

Deployment workflow:


---

# Configuration Management

After infrastructure deployment, Ansible configures the virtual machine and prepares the environment for application execution.

```mermaid
flowchart LR

A[VM Provisioned]
--> B[Generate Inventory]
--> C[Run Ansible Playbook]
--> D[Install Dependencies]
--> E[Run Cosmos SDK Application]

```


# Deployment Validation 

Terraform Infrastructure Deployment

<p align="center"> <img src="docs/images/Terraform-Apply.gif" width="900"> </p>


VM Connectivity Validation

<p align="center"> <img src="docs/images/SSH-Confirmation.gif" width="900"> </p>


<p align="center">  Successful Ansible Deployment  </p>

<p align="center"> <img src="docs/images/ansible-config.gif" width="900"> </p>

Cosmos DB Data Explorer showing documents inserted by the automated batch ingestion process

<p align="center"> <img src="docs/images/Batch-Insert-Confirmation.gif" width="900"> </p>

<p align="center"> <img src="docs/images/Metrics-Confirmation.gif" width="900"> </p>


