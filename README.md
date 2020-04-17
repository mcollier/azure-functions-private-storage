# Azure Functions with a private storage account

:construction: This is still under development! :construction:

This is a sample showing how to set up Azure Functions to use a vnet restricted (private) storage account.  There are a few caveats, which are called out below.

The Azure Function app provisioned in this sample uses an Azure Functions Premium plan.  The Premium plan is used to enable virtual network integration.  Virtual network integration is significant in this sample as a storage account used by the function app is access restricted to the virtual network.

There are two Azure Storage accounts created in this sample:

- one storage account that uses a service endpoint to restrict access to a specific vnet and subnet
- one storage account with no virtual network restrictions

The storage account with no virtual network restrictions (indicated by the [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) setting) will contain the application code.

The storage account with virtual network restrictions (indicated by the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) setting) will host metadata (keys, trigger metadata, etc.) used by the Azure Functions runtime.
