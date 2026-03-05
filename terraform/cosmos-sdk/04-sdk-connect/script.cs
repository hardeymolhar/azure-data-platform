using System;
using System.Linq;
using Microsoft.Azure.Cosmos;
using System.Threading.Tasks;
 
class Program
{
    static async Task Main(string[] args)
    {
        string endpoint = Environment.GetEnvironmentVariable("COSMOS_ENDPOINT");
        string key = Environment.GetEnvironmentVariable("COSMOS_KEY");
 
        CosmosClient client = new CosmosClient(endpoint, key);
 
        AccountProperties account = await client.ReadAccountAsync();
        Console.WriteLine($"Account Name:\t{account.Id}");
        Console.WriteLine($"Primary Region:\t{account.WritableRegions.FirstOrDefault()?.Name}");
    }
}