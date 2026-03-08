# Phase 3 --- Automated Infrastructure Deployment and System Orchestration

## Project Progression

  -----------------------------------------------------------------------
  Phase                               Focus
  ----------------------------------- -----------------------------------
  Phase 1                             Establish Cosmos DB connectivity
                                      using the .NET SDK

  Phase 2                             Implement efficient ingestion using
                                      Transactional Batch

  Phase 3                             Automate infrastructure deployment
                                      and application execution
  -----------------------------------------------------------------------

Phase 3 transitions the project from manual testing to automated
deployment and execution.

------------------------------------------------------------------------

## System Architecture

```mermaid
flowchart LR

subgraph CI/CD Pipeline
A[Terraform Init]
B[Terraform Plan]
C[Terraform Apply]
end

subgraph Azure Infrastructure
D[Virtual Network]
E[Subnets]
F[Network Security Groups]
G[Virtual Machine]
H[Cosmos DB]
end

subgraph Configuration
I[Ansible Playbook]
J[.NET SDK Application]
end

A --> B --> C

C --> D
D --> E
E --> F
F --> G

G --> I
I --> J

J --> H
```

Replace the image below with your architecture diagram if available.

```{=html}
<p align="center">
```
`<img src="images/phase3-architecture.png" width="900">`{=html}
```{=html}
</p>
```
The architecture connects infrastructure provisioning, server
configuration, and application execution into one automated workflow.

------------------------------------------------------------------------

## Problem Context

In the earlier phases, key capabilities were validated manually:

-   The .NET SDK could authenticate and connect to Cosmos DB.
-   Transactional batch operations could insert documents efficiently.

However, several tasks still required manual execution:

-   deploying infrastructure
-   configuring the virtual machine
-   executing the SDK application
-   running ingestion tests

This made the environment difficult to recreate consistently.

The objective of Phase 3 was to automate the entire workflow, from
infrastructure deployment to data ingestion.

------------------------------------------------------------------------

# Engineering Flow

The automation introduced in Phase 3 follows a structured progression.

``` mermaid
flowchart LR

A[Manual Validation<br>Phase 1 & Phase 2]
--> B[Automate Infrastructure<br>Terraform]

B --> C[Automate Server Configuration<br>Ansible]

C --> D[Run .NET SDK Application]

D --> E[Transactional Batch Inserts]
```

------------------------------------------------------------------------

# Infrastructure Deployment

Terraform provisions the infrastructure required for the platform.

## Terraform Resource Dependency Graph

The following graph shows how Terraform resources are related and
deployed.

Key dependencies include:

- Virtual network and subnet configuration
- Network security rules
- Virtual machine deployment
- Cosmos DB account provisioning

```{=html}
<p align="center">
```
`<img src="images/terraform-graph.png" width="900">`{=html}
```{=html}
</p>
```
This graph was generated using:

``` bash
terraform graph | dot -Tpng > terraform-graph.png
```

The visualization shows the dependency relationships between networking
resources, compute infrastructure, and Cosmos DB services.

------------------------------------------------------------------------

## Simplified Infrastructure View

``` mermaid
flowchart TD

A[Terraform Configuration]

A --> B[Virtual Network]
A --> C[Subnets]
A --> D[Network Security Groups]
A --> E[Virtual Machine]
A --> F[Cosmos DB Account]
A --> G[Supporting Services]
```

Infrastructure deployment follows a consistent workflow.

``` bash
terraform init
terraform validate
terraform fmt
terraform plan
terraform apply
```

------------------------------------------------------------------------

## Terraform Graph & Deployment Evidence

```{=html}
<p align="center">
```
`<img src="images/terraform-apply.png" width="900">`{=html}
```{=html}
</p>
```
The Terraform pipeline provisions the infrastructure resources required
for the environment.

------------------------------------------------------------------------

# VM Connectivity Validation

Before configuration begins, the virtual machine must be reachable.

``` mermaid
flowchart LR
A[Local Environment]
--> B[Ping VM]
--> C[SSH Access]
--> D[Ready for Configuration]
```

------------------------------------------------------------------------

## Ping Test to VM

```{=html}
<p align="center">
```
`<img src="images/ping-vm-test.png" width="900">`{=html}
```{=html}
</p>
```
The ping test confirms that the virtual machine is reachable through the
configured network.

------------------------------------------------------------------------

# SSH Access to the VM

Once connectivity is confirmed, SSH access validates authentication and
network rules.

``` mermaid
flowchart LR
A[Local Machine]
--> B[SSH Key Authentication]
--> C[Azure VM]
```

------------------------------------------------------------------------

## SSH Connection Screenshot

```{=html}
<p align="center">
```
`<img src="images/ssh-connection.png" width="900">`{=html}
```{=html}
</p>
```
Successful SSH access confirms that the VM is ready for configuration.

------------------------------------------------------------------------

# Server Configuration

Once infrastructure is deployed, the virtual machine must be configured
before running the application.

Ansible automates this configuration.

``` mermaid
flowchart LR

A[VM Created]
--> B[Generate Ansible Inventory]

B --> C[Run Ansible Playbook]

C --> D[Install Dependencies]

D --> E[Execute .NET SDK Application]

E --> F[Transactional Batch Inserts]
```

------------------------------------------------------------------------

# Network Architecture Constraint

The original architecture intended to use Cosmos DB Private Endpoints.

Terraform configuration for this design exists in the project:

``` bash
terraform/private-endpoints-with-vnet-link.tf
```

This configuration defines:

-   Cosmos DB private endpoint
-   Private DNS zone
-   VNet DNS link

However, private endpoint access requires connectivity into the virtual
network through a VPN gateway.

Due to RBAC restrictions, deployment of a Point-to-Site VPN gateway was
not possible.

Because of this limitation, the architecture was adjusted.

------------------------------------------------------------------------

# Final Network Design

``` mermaid
flowchart LR

subgraph Virtual Network
A[Application VM]
end

A --> B[Service Endpoint]

B --> C[Azure Cosmos DB]

D[External Traffic]
--> E[Cosmos DB IP Filtering]

E --> C
```

The final implementation uses:

-   Service Endpoints
-   Cosmos DB IP filtering
-   Application VM inside the VNet

This configuration allows the application to access Cosmos DB securely
without requiring a VPN.

------------------------------------------------------------------------

# Failures Encountered and Engineering Fixes

Documenting failures was an important part of this phase.

## 1. Private Endpoint Deployment Constraint

**Problem**

Private endpoints were implemented in Terraform but could not be used
because VPN gateway deployment required permissions not available under
the assigned RBAC role.

**Evidence**

    terraform/private-endpoints-with-vnet-link.tf

**Resolution**

The architecture was adjusted to use:

-   Service Endpoints
-   Cosmos DB IP filtering

This allowed the VM to communicate with Cosmos DB without VPN
connectivity.

------------------------------------------------------------------------

## 2. Secret Retrieval Limitation

Earlier phases attempted to follow best practice by retrieving
credentials from Key Vault.

However the executing identity lacked **data plane permissions**.

**Solution**

A script was created to retrieve Cosmos DB keys using the Azure CLI.

    fetch-keys.sh

This script retrieves the primary key directly from the Cosmos DB
account.

------------------------------------------------------------------------

## 3. Partition Key Validation

During ingestion testing it was necessary to confirm that containers
were configured with the expected partition keys.

A validation script was implemented:

    fetch_partition_key.sh

This script:

-   enumerates databases
-   lists containers
-   retrieves partition key paths

This ensured batch operations executed against the expected partition
structure.

------------------------------------------------------------------------

## 4. VM Environment Preparation

The VM initially lacked the environment required to execute the SDK
application.

Initial attempts using ad‑hoc scripts became complex and difficult to
maintain. After spending significant time attempting to make these
scripts idempotent, the approach was replaced with Ansible playbooks.

Ansible was introduced to:

-   install runtime dependencies
-   configure the development environment
-   prepare the system for application execution

These configuration files are stored in:

    terraform/config-files/

------------------------------------------------------------------------

# Cosmos DB Application Execution

Once the environment is prepared, the .NET application connects to
Cosmos DB and executes batch operations.

```{=html}
<p align="center">
```
`<img src="images/sdk-batch-run.png" width="900">`{=html}
```{=html}
</p>
```
The ingestion logic uses transactional batch operations validated in
Phase 2.

------------------------------------------------------------------------

# End-to-End Workflow

``` mermaid
flowchart LR

A[Terraform Deploy Infrastructure]

--> B[VM Provisioned]

--> C[Connectivity Validation]

--> D[Ansible Server Configuration]

--> E[Run .NET SDK Application]

--> F[Transactional Batch Inserts]
```

------------------------------------------------------------------------

# Measurable Outcome

  -----------------------------------------------------------------------
  Area                             Result
  -------------------------------- --------------------------------------
  Infrastructure                   Automated deployment using Terraform

  Server Setup                     Automated VM configuration using
                                   Ansible

  Connectivity                     Network access validated through ping
                                   and SSH

  Deployment                       Environment reproducible across
                                   deployments

  Data Ingestion                   Transactional batch operations
                                   executed automatically
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# Key Lessons From Phase 3

## Infrastructure Automation Improves Reliability

Replacing manual setup with automated workflows allows the environment
to be recreated consistently.

## Design Must Adapt to Constraints

RBAC restrictions prevented deployment of the VPN gateway required for
private endpoints.

Adjusting the design to use service endpoints allowed the project to
proceed.

## Validation Scripts Improve Confidence

Scripts used to retrieve Cosmos DB keys and audit partition keys ensured
the deployed environment matched expected configuration.
