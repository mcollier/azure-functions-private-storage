using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Company.Function
{
    public static class MyFunctions
    {
        [FunctionName("QueueTrigger")]
        public static async Task GetMessagesFunctionsAsync(
                    [QueueTrigger("%QueueName%", Connection = "PrivateEndpointStorage")] string queueItem,
                    [CosmosDB(
                        databaseName: "%CosmosDbName%",
                        collectionName: "%CosmosDbCollectionName%",
                        ConnectionStringSetting = "CosmosDBConnection")]
                        IAsyncCollector<string> items,
                        ILogger logger)
        {
            logger.LogInformation($"Queue trigger processed: {queueItem}");

            await items.AddAsync(queueItem);
        }
    }
}
