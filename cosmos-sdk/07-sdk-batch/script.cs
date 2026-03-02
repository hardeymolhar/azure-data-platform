using System;
using Microsoft.Azure.Cosmos;

string endpoint = Environment.GetEnvironmentVariable("COSMOS_ENDPOINT");
string key = Environment.GetEnvironmentVariable("COSMOS_KEY");

CosmosClient client = new CosmosClient(endpoint, key);
    
Database database = client.GetDatabase("mycosmosdb");
Container container = database.GetContainer("items");

// Use this if POST is supported

//Database database = await client.CreateDatabaseIfNotExistsAsync("mycosmosdb");
//Database container  = await client.CreateContainerIfNotExistsAsync("products", "/categoryId", 400);

Product csproj = new("012B", "Torn Bill", "9603ca6c-9e28-4a02-9194-51cdb7fea816");
Product little = new("012C", "Krud Ruger", "9603ca6c-9e28-4a02-9194-51cdb7fea816");
PartitionKey partitionKey = new ("9603ca6c-9e28-4a02-9194-51cdb7fea816");

TransactionalBatch batch = container.CreateTransactionalBatch(partitionKey)
  .CreateItem<Product>(csproj)
  .CreateItem<Product>(little);

using TransactionalBatchResponse response = await batch.ExecuteAsync(); 
Console.WriteLine($"Status:\t{response.StatusCode}");
