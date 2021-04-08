using System.IO;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using System.Linq;

namespace Company.Function
{
    public static class MyFunctions
    {
        [FunctionName("CensusDataFilesFunction")]
        public static async Task ProcessCensusDataFiles(
            [BlobTrigger("%ContainerName%/{blobName}", Connection = "CensusResultsAzureStorageConnection")] Stream myBlobStream,
            string blobName,
            [CosmosDB(
                databaseName: "%CosmosDbName%",
                collectionName: "%CosmosDbCollectionName%",
                ConnectionStringSetting = "CosmosDBConnection")] IAsyncCollector<string> items,
            ILogger logger)
        {
            logger.LogInformation($"C# Blob trigger function processed blob of name '{blobName}' with size of {myBlobStream.Length} bytes");

            var jsonObject = await ConvertCsvToJsonAsync(myBlobStream);

            foreach (var item in jsonObject)
            {
                await items.AddAsync(JsonConvert.SerializeObject(item));
            }
        }

        private static async Task<IEnumerable<JObject>> ConvertCsvToJsonAsync(Stream csvStream)
        {
            string[] header = { };

            List<JObject> jsonObjects = new List<JObject>();

            using (var streamReader = new StreamReader(csvStream))
            {
                string line = null;

                while ((line = await streamReader.ReadLineAsync()) != null)
                {
                    // Assume the first line contains the headers. Dangerous assumption?
                    if (header.Length == 0)
                    {
                        header = line.Split(',').Select(h => h.Trim()).ToArray();
                    }
                    else
                    {
                        // Assume all other lines are data elements.

                        // https://stackoverflow.com/a/50741265

                        string[] lineItem = line.Split(',').Select(i => i.Trim()).ToArray();
                        var itemWithHeader = header.Zip(lineItem, (h, v) => new KeyValuePair<string, string>(h, v));
                        var jsonItem = new JObject(itemWithHeader.Select(j => new JProperty(j.Key, j.Value)));

                        jsonObjects.Add(jsonItem);
                    }
                }
            }

            return jsonObjects;
        }

        [FunctionName("EventHubTriggerCSharp")]
        public static void Run(
            [EventHubTrigger("%EventHubName%", Connection = "EventHubConnectionAppSetting")] string myEventHubMessage,
            [Blob("events/{rand-guid}.txt", FileAccess.Write)] out string outputMessage,
            ILogger log)
        {
            log.LogInformation($"C# function triggered to process a message: {myEventHubMessage}");
            outputMessage = myEventHubMessage;
        }
    }
}
