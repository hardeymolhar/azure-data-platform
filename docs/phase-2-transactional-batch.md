# Phase 2 — Transactional Batch Operations for Bulk Inserts

## Problem Context

Inserting documents individually increases network overhead and Request Unit (RU) consumption.

Azure Cosmos DB provides **Transactional Batch**, allowing multiple operations to execute atomically within a single partition key.

---

## Engineering Decisions

### Use Transactional Batch

Transactional batch was selected to:

- reduce network calls
- improve write efficiency
- maintain atomic consistency within a partition

---

### Throughput Model Selection

Azure Cosmos DB allows throughput to be configured either at the **container level (dedicated throughput)** or at the **database level (shared throughput)**.

In this project, **database-level shared throughput** was intentionally selected instead of provisioning dedicated throughput for each container.

This decision was made for the following reasons.

#### Predictable Workload

The transactional batch operations executed in this phase generate a controlled and predictable number of write operations. Because the workload characteristics are known in advance, a shared throughput pool is sufficient to handle the expected request volume.

#### Lab / Sandbox Environment

This project was executed in a controlled sandbox environment designed to validate SDK behavior and batching functionality rather than support production traffic. Shared throughput provides adequate performance while minimizing unnecessary resource allocation.

#### Cost Efficiency

Dedicated throughput allocates Request Units (RU/s) to each container individually. In environments where containers are not consistently active, this can lead to underutilized capacity.

Using shared throughput allows multiple containers within the database to consume RU/s from a common pool, improving utilization and reducing overall cost.

The screenshots below demonstrate the difference between container-level dedicated throughput and database-level shared throughput.

---

### Dedicated Throughput (Container Level)

![Dedicated Throughput Configuration](images/dedicated-throughput.png)

Dedicated throughput assigns RU/s directly to a specific container. Each container must have its own provisioned throughput, which can lead to unused capacity if workloads are inconsistent.

---

### Shared Throughput (Database Level)

![Shared Throughput Configuration](images/shared-throughput.png)

Shared throughput provisions RU/s at the database level, allowing multiple containers to share the same throughput pool. This improves resource utilization and reduces operational overhead.

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

Each batch executes atomically within the specified partition key.

If any operation within the batch fails, the entire batch fails and the transaction is rolled back.