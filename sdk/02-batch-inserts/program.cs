/*
This script iterates through all databases and containers in an Azure Cosmos DB account
and performs both data insertion and query workload simulation.

For each container:
- The partition key path is dynamically retrieved.
- A set of 200 documents is generated in memory with randomized values
  (category, price, quantity, status, region, rating, createdAt).
- All documents share the same partition key value to allow use of TransactionalBatch.

Data Insertion:
- Documents are inserted in batches (100 items per batch) using TransactionalBatch.
- Each batch is scoped to a single partition key value to ensure atomic execution.
- Request Unit (RU) consumption is logged for each batch.

Query Workload Simulation:
- After successful insertion, randomized queries are executed against the same partition.
- Queries follow a consistent pattern: SELECT ... WHERE ... ORDER BY ...
- Query predicates and parameter values are dynamically generated to simulate real-world access patterns.
- RU consumption and result counts are logged for each query.

Purpose:
- Simulate both write and read workloads
- Observe RU consumption for inserts and queries
- Validate partition key behavior
- Evaluate query patterns for indexing decisions

Non-Goals:
- This is not a production ingestion pipeline
- Does not implement parallelism, retry policies, or cross-partition querying
- Does not represent optimal throughput or scalability patterns

This script is intended for testing, experimentation, and performance analysis.
*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.Cosmos;

public class Program
{
    private static readonly Random rand = new Random();

    private static readonly string[] Categories =
    {
        "electronics", "books", "fashion", "home", "sports"
    };

    private static readonly string[] Statuses =
    {
        "active", "pending", "inactive"
    };

    private static readonly string[] Regions =
    {
        "us-east", "us-west", "eu-west", "af-south", "ap-south"
    };

    public static async Task Main(string[] args)
    {
        string endpoint = Environment.GetEnvironmentVariable("COSMOS_ENDPOINT");
        string key = Environment.GetEnvironmentVariable("COSMOS_KEY");

        if (string.IsNullOrWhiteSpace(endpoint) || string.IsNullOrWhiteSpace(key))
        {
            Console.WriteLine("Missing COSMOS_ENDPOINT or COSMOS_KEY.");
            return;
        }

        CosmosClient client = new CosmosClient(endpoint, key);

        FeedIterator<DatabaseProperties> dbIterator =
            client.GetDatabaseQueryIterator<DatabaseProperties>();

        while (dbIterator.HasMoreResults)
        {
            foreach (var dbProps in await dbIterator.ReadNextAsync())
            {
                Database database = client.GetDatabase(dbProps.Id);
                Console.WriteLine($"\nDatabase: {dbProps.Id}");

                FeedIterator<ContainerProperties> containerIterator =
                    database.GetContainerQueryIterator<ContainerProperties>();

                while (containerIterator.HasMoreResults)
                {
                    foreach (var containerProps in await containerIterator.ReadNextAsync())
                    {
                        Console.WriteLine($"  Container: {containerProps.Id}");

                        string pkPath = containerProps.PartitionKeyPath;
                        string pkProperty = pkPath.TrimStart('/');

                        Console.WriteLine($"    Partition Key: {pkProperty}");

                        Container container = database.GetContainer(containerProps.Id);

                        string partitionValue = Guid.NewGuid().ToString();

                        List<Dictionary<string, object>> items = new();

                        for (int i = 1; i <= 200; i++)
                        {
                            items.Add(CreateRandomItem(pkProperty, partitionValue, i));
                        }

                        int batchSize = 100;
                        int batchNumber = 1;
                        bool allBatchesSucceeded = true;

                        for (int i = 0; i < items.Count; i += batchSize)
                        {
                            var chunk = items.Skip(i).Take(batchSize);

                            TransactionalBatch batch =
                                container.CreateTransactionalBatch(
                                    new PartitionKey(partitionValue));

                            foreach (var item in chunk)
                            {
                                batch.CreateItem(item);
                            }

                            using TransactionalBatchResponse response =
                                await batch.ExecuteAsync();

                            Console.WriteLine(
                                $"      Batch {batchNumber} Status: {response.StatusCode}");

                            Console.WriteLine(
                                $"      RU Charge: {response.RequestCharge:0.00}");

                            if (!response.IsSuccessStatusCode)
                            {
                                allBatchesSucceeded = false;
                                Console.WriteLine($"      Error: {response.ErrorMessage}");
                                break;
                            }

                            batchNumber++;
                        }

                        if (allBatchesSucceeded)
                        {
                            await RunRandomQueries(container, partitionValue);
                        }
                    }
                }
            }
        }
    }

    private static Dictionary<string, object> CreateRandomItem(
        string pkProperty,
        string partitionValue,
        int i)
    {
        string category = Categories[rand.Next(Categories.Length)];
        string status = Statuses[rand.Next(Statuses.Length)];
        string region = Regions[rand.Next(Regions.Length)];

        double price = Math.Round(50 + (rand.NextDouble() * 950), 2);
        int quantity = rand.Next(1, 100);
        double rating = Math.Round(1 + (rand.NextDouble() * 4), 1);
        DateTime createdAt = DateTime.UtcNow.AddMinutes(-rand.Next(0, 60 * 24 * 30));

        return new Dictionary<string, object>
        {
            ["id"] = Guid.NewGuid().ToString(),
            ["name"] = $"Item {i}",
            ["category"] = category,
            ["price"] = price,
            ["quantity"] = quantity,
            ["status"] = status,
            ["region"] = region,
            ["rating"] = rating,
            ["createdAt"] = createdAt,
            [pkProperty] = partitionValue
        };
    }

private static QueryDefinition CreateRandomQuery()
{
    return rand.Next(5) switch
    {
        0 => new QueryDefinition(
                "SELECT * FROM c WHERE c.category = @category ORDER BY c.price ASC")
            .WithParameter("@category", Categories[rand.Next(Categories.Length)]),

        1 => new QueryDefinition(
                "SELECT * FROM c WHERE c.price > @price ORDER BY c.createdAt DESC")
            .WithParameter("@price", rand.Next(100, 600)),

        2 => new QueryDefinition(
                "SELECT * FROM c WHERE c.status = @status ORDER BY c.rating DESC")
            .WithParameter("@status", Statuses[rand.Next(Statuses.Length)]),

        3 => new QueryDefinition(
                "SELECT * FROM c WHERE c.region = @region ORDER BY c.createdAt DESC")
            .WithParameter("@region", Regions[rand.Next(Regions.Length)]),

        _ => new QueryDefinition(
                "SELECT * FROM c WHERE c.rating >= @rating ORDER BY c.price ASC")
            .WithParameter("@rating", Math.Round(2 + (rand.NextDouble() * 3), 1))
    };
}
}