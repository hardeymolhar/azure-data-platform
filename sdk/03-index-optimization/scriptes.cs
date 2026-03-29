using Microsoft.Azure.Cosmos;
using System.Text.Json;

string json = await File.ReadAllTextAsync("sample.json");

json = json.Replace("<unique-identifier>", $"{Guid.NewGuid()}");

Product? item = JsonSerializer.Deserialize<Product>(json);

if (item is null)
{
    Console.WriteLine("JSON deserialization failed.");
    return;
}

List<Task> tasks = new();

FeedIterator<DatabaseProperties> dbIterator = client.GetDatabaseQueryIterator<DatabaseProperties>();

while (dbIterator.HasMoreResults)
{
    foreach (DatabaseProperties db in await dbIterator.ReadNextAsync())
    {
        Database database = client.GetDatabase(db.Id);

        FeedIterator<ContainerProperties> containerIterator =
            database.GetContainerQueryIterator<ContainerProperties>();

        while (containerIterator.HasMoreResults)
        {
            foreach (ContainerProperties containerProps in await containerIterator.ReadNextAsync())
            {
                tasks.Add(Task.Run(async () =>
                {
                    try
                    {
                        Container container = database.GetContainer(containerProps.Id);

                        ContainerResponse metadata = await container.ReadContainerAsync();

                        string partitionPath =
                            metadata.Resource.PartitionKeyPath.Replace("/", "");

                        object? partitionValue =
                            item.GetType().GetProperty(partitionPath)?.GetValue(item);

                        PartitionKey pk =
                            partitionValue != null
                            ? new PartitionKey(partitionValue.ToString())
                            : PartitionKey.None;

                        ItemResponse<Product> response =
                            await container.UpsertItemAsync(item, pk);

                        Console.WriteLine(
                            $"{db.Id}/{containerProps.Id} | RU: {response.RequestCharge:0.00}");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine(
                            $"FAILED: {db.Id}/{containerProps.Id} → {ex.Message}");
                    }
                }));
            }
        }
    }
}

await Task.WhenAll(tasks);

Console.WriteLine("Completed broadcast insert.");