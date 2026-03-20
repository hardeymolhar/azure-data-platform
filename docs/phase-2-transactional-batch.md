# Phase 2 — Transactional Batch Operations for Bulk Inserts

```mermaid
flowchart LR
A[Problem<br>High RU + Network Overhead]
--> B[Solution<br>Transactional Batch]
--> C[Implementation<br>SDK Batch Insert]
--> D[Observation<br>~895 RU Consumption]
--> E[Next Phase<br>Optimize Indexing]
```

## Problem --> Outcome

**Problem**: Per-document inserts produced excessive network overhead and higher RU cost.

**Solution chosen**: TransactionalBatch for atomic multi-operation writes within the same partition, grouped into batches of 100 items. This reduces network round trips and enforces atomicity for batch items.

**Outcome observed**: Two batches inserting a total of 200 documents consumed ~895 RU (≈4.5 RU/document), matching the expected RU model given default indexing and document shapes.

---

## Engineering Decisions

### Decision 1 - Use Transactional Batch

Transactional batch was selected to:

- reduce network calls
- improve write efficiency
- maintain atomic consistency within a partition

---

### Decision 2 - Throughput Model Selection

```mermaid
xychart-beta
    title Dedicated vs Shared Throughput Tradeoff
    x-axis ["Cost Efficiency","Isolation","Operational Simplicity","Scalability"]
    y-axis Score 0 --> 10
    bar [9,3,9,6]
    bar [4,9,5,9]

```
<div align="center">

Legend

| Color | Throughput Model |
|------|------------------|
| Green | Dedicated Throughput |
| Blue | Shared Throughput |

#### Interpretation

Shared throughput scores higher for :
 cost efficiency and 
 operational simplicity 

Why?     because containers share a single RU pool.

Dedicated throughput scores higher for 
 isolation 
 scalability

Why?     each container has guaranteed RU allocation.




</div>


### Throughput Architecture

```mermaid
flowchart LR

subgraph Dedicated Throughput
A[Container A<br>400 RU/s]
B[Container B<br>400 RU/s]
C[Container C<br>400 RU/s]
end

subgraph Shared Throughput
D[Database RU Pool<br>400 RU/s]
E[Container 1]
F[Container 2]
G[Container 3]
end

D --> E
D --> F
D --> G
```




### Final Decision
```bash
Because this project runs inside a controlled lab environment, cost efficiency and simplicity were prioritized 
and it led to intentionally choosing database level shared throughput
```

| Factor | Reason |
|-------|--------|
| Predictable Workload | Batch operations generate controlled write volumes |
| Lab Environment | Not a production workload |
| Cost Efficiency | Prevents unused RU allocation |
---

# Configuration Screenshots

Throughputs were chosen one after the order in order to demonstrate how they actually work and look like in Azure

## Dedicated Throughput (Container Level)

![Dedicated Throughput Configuration](images/dedicated-throughput.png)

---

## Shared Throughput Configuration

![Shared Throughput Configuration](images/shared-throughput.png)


---

## Technical Implementation

Documents are grouped into batches of **100 items** and inserted using the Cosmos DB `TransactionalBatch` API.

```csharp
TransactionalBatch batch =
    container.CreateTransactionalBatch(
        new PartitionKey(partitionValue));

foreach (var item in chunk)
{
    batch.CreateItem(item);
}

TransactionalBatchResponse response =
    await batch.ExecuteAsync();
```

## Batch Model Execution

```mermaid
flowchart LR
A[Generate Partition Key]
--> B[Create Items]
--> C[Group Items Into Batches]
--> D[Create Transactional Batch]
--> E[Execute Batch]
--> F[Validate StatusCode]
```

Each batch executes atomically within the specified partition key.

If any operation within the batch fails:

- the entire batch fails

- all operations are rolled back

- the transaction is not committed



![Dedicated Throughput Configuration](images/Batch-Insert-With-RU.gif)

![Dedicated Throughput Configuration](images/Batch-Insert.gif)


# OBSERVABILITY - RU CONSUMPTION REPORT

## CosmosDB Write Lifecycle 

When a client application inserts or updates a document in Azure Cosmos DB, the request travels through several internal components before the operation completes. Each stage performs work that contributes to the final Request Unit (RU) charge, which represents the amount of compute, memory, and I/O resources consumed by the operation.

```mermaid
flowchart LR
Client[Application Request]
--> Router[Partition Router]
--> Storage[Storage Engine]
--> Index[Index Updates]
--> RU[RU Charge]
```

## RU Consumption Calculation
When performing write operations in Azure Cosmos DB, each request consumes Request Units (RU). A Request Unit represents the normalized cost of performing a database operation based on the amount of system resources consumed, including CPU, memory, disk I/O, and indexing overhead.

In this experiment, RU consumption was measured during the insertion of 200 documents using TransactionalBatch operations.

```mermaid
flowchart LR
    A[Insert Operation] --> B[~4.5 RU per document]
    B --> C[200 Documents]
    C --> D[≈ 900 RU Total]
    D --> E[Observed ~895 RU]
```

![Log Analytics Screenshot](images/Log-Analytics.gif)

## Why Did this transaction consume 895.24 RU?

```bash
The transaction consumes 895.24 RU because it performs two transactional batches inserting 200 documents into a single logical partition in Azure Cosmos DB.
Also, The items use the default cosmosdb indexing policy which contains many **indexed fields**, so Cosmos must write the document + update multiple indexes, which increases RU consumption.
```
From the index policy shown above under cosmosdb data explorer, It is apparent that all paths are indexed:
```mermaid
graph LR
    Doc[Document] --> id[id]
    Doc --> name[name]
    Doc --> category[category]
    Doc --> price[price]
    Doc --> quantity[quantity]
    Doc --> status[status]
    Doc --> region[region]
    Doc --> rating[rating]
    Doc --> createdAt[createdAt]
    Doc --> partitionKey[partitionKey]
    
    id --> Index1[Indexed]
    name --> Index2[Indexed]
    category --> Index3[Indexed]
    price --> Index4[Indexed]
    quantity --> Index5[Indexed]
    status --> Index6[Indexed]
    region --> Index7[Indexed]
    rating --> Index8[Indexed]
    createdAt --> Index9[Indexed]
    partitionKey --> Index10[Indexed]
```

The following are factors that drive RU consumption in azure cosmosdb
```mermaid
graph TD
    RU[RU Consumption Drivers] --> Writes[Number of Writes]
    RU --> Size[Document Size]
    RU --> Index[Indexing Overhead]
    RU --> Batch[Transactional Batch Overhead]
    RU --> Properties[Number of Indexed Properties]
```


The next phases hopes to answer the engineering question
```bash
How might we reduce RU consumption while optimizing container indexing policy for common operations and specific queries
```

# Key Lessons From Phase 2

## Introducing Terraform Module Architecture
The initial Terraform configuration defined most infrastructure resources directly within a single configuration structure. While functional for experimentation, this approach becomes difficult to maintain as infrastructure grows.

![Dedicated Throughput Configuration](images/directory-view.png)

Challenges included:

```mermaid
flowchart LR
A[Single Terraform Configuration] --> B[Repeated Configuration Blocks]
B --> C[Limited Reusability]
C --> D[Difficult Environment Separation]
```
```mermaid
flowchart TD
D[Problems Identified] --> E[Refactor to Terraform Modules]
```



```mermaid
flowchart TD
F[Reusable Infrastructure Components] --> G[Dev Environment]
F --> H[Prod Environment]
```



## Confusion Between Terraform Argument Types
What Happened

While implementing networking resources, I initially struggled with Terraform schema requirements regarding argument types such as:

-**string**

-**list(string)**

-**map(object(...))**

This led to an incorrect configuration where the expression was interpreted as a literal string instead of a variable reference.

```mermaid
flowchart LR
A[Infrastructure Design] --> D[Better Cloud Engineering]
B[Terraform Type Understanding] --> D
C[Strengthening Infrastructure Security] --> D
```