/* This script performs a **dynamic bulk data insertion across all databases and containers in an Azure Cosmos DB account**.

It programmatically discovers every database and container, retrieves each container’s partition key definition,
and generates sample documents that include the correct partition key field for that container.
 
For each container, it creates a set of items and inserts them in batches using `TransactionalBatch`, ensuring all operations occur within the same partition for efficiency and atomicity.

The primary purpose of this script is to **simulate workload, test partition key handling, and measure RU consumption across multiple containers**,
rather than serve as a production data ingestion pipeline.
It demonstrates how to dynamically adapt to different container schemas and partition strategies within a single Cosmos DB account.
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
