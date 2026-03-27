/*
This script automatically goes through all databases and containers in an Azure Cosmos DB account
and inserts sample data into them.

Instead of reading data from a file or external source, it generates the data in memory.
Each container’s partition key is detected, and the generated data is adjusted to match it.

The data is inserted in small groups (batches) using TransactionalBatch.
Each batch is limited to a single partition, which allows all items in that batch
to be written together successfully or fail together.

This script is mainly used for testing purposes, such as:
- Simulating data load
- Checking how partition keys are handled
- Observing request unit (RU) consumption

It is not designed for real-world data ingestion or large-scale production use.

*/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.Cosmos;

public class Program
{
    public static async Task Main(string[] args)
    {
        string endpoint = Environment.GetEnvironmentVariable("COSMOS_ENDPOINT");
        string key = Environment.GetEnvironmentVariable("COSMOS_KEY");

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

                        Container container =
                            database.GetContainer(containerProps.Id);

                        string partitionValue = Guid.NewGuid().ToString();

                        List<Dictionary<string, object>> items = new();

                        for (int i = 1; i <= 200; i++)
                        {
                            items.Add(new Dictionary<string, object>
                            {
                                ["id"] = Guid.NewGuid().ToString(),
                                ["name"] = $"Item {i}",
                                ["category"] = "electronics",
                                ["price"] = 199.99,
                                ["quantity"] = 25,
                                ["status"] = "active",
                                ["region"] = "us-east",
                                ["rating"] = 4.5,
                                ["createdAt"] = DateTime.UtcNow,
                                [pkProperty] = partitionValue
                            });
                        }

                        int batchSize = 100;
                        int batchNumber = 1;

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
                                Console.WriteLine($"      Error: {response.ErrorMessage}");
                                break;
                            }

                            batchNumber++;
                        }
                    }
                }
            }
        }
    }
}
