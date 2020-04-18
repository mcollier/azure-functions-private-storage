# Azure Functions with a private storage account

:construction: This is still under development! :construction:

This is a sample showing how to set up Azure Functions to use a vnet restricted (private) storage account.  

## Summary

The Azure Function app provisioned in this sample uses an Azure Functions Premium plan.  The Premium plan is used to enable virtual network integration.  Virtual network integration is significant in this sample as a storage account used by the function app is access restricted to the virtual network.

There are two Azure Storage accounts created in this sample:

- one storage account that uses a service endpoint to restrict access to a specific vnet and subnet
- one storage account with no virtual network restrictions

The storage account with no virtual network restrictions (indicated by the [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) setting) will contain the application code.

The storage account with virtual network restrictions (indicated by the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) setting) will host metadata (keys, trigger metadata, etc.) used by the Azure Functions runtime.

## Deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Fmcollier%2Fazure-functions-private-storage.git)

Execute the [ARM template in the template directory](./template/azuredeploy.json).  The ARM template will provision the following resources:

- two storage accounts (one storage account will have a virtual network rule)
- virtual network with one subnet
- Application Insights
- Azure Functions Premium plan and function app with vnet integration enabled
