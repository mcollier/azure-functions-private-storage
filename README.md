# Azure Functions with Private Endpoints

:construction: This is still under development! :construction:

![Build .NET Core](https://github.com/mcollier/azure-functions-private-storage/workflows/Build%20.NET%20Core/badge.svg)

## Summary

This sample shows how to use Azure Functions with [private endpoints](https://docs.microsoft.com/azure/private-link/private-endpoint-overview) for Azure Storage and CosmosDB.  The use of private endpoints enables private (vnet only) access to designated Azure resources.

One of the key scenarios in this sample is the use of Azure Storage private endpoints with the storage account required for use with Azure Functions.  Azure Functions uses a storage account for metadata related to the runtime and various triggers.  The storage account is referenced via the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) application setting.  The *AzureWebJobsStorage* account will be configured for access via private endpoints.

It is currently not possible to use the storage account referenced by *AzureWebJobsStorage* for the Azure Function's application code **[if that storage account uses any virtual network restrictions](https://docs.microsoft.com/azure/azure-functions/functions-networking-options#restrict-your-storage-account-to-a-virtual-network)**.  Therefore, another Azure Storage account, without virtual network restrictions, is needed.

## Deployment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Fmcollier%2Fazure-functions-private-storage.git)

### Prerequisites

### Resource Manager Template

Execute the [ARM template in the template directory](./template/azuredeploy.json).  A [script](./template/deploy.sh) is provided to deploy the template.

## Architecture Overview

This sample will demonstrate an Azure Function which retrieves files from an Azure Storage blob container, performs simple operations against the retrieved file data, and finally persists the data to an Azure CosmosDB collection.  The function will communicate with the source Azure Storage account and the destination CosmosDB collection via private endpoints.  

![Architecture diagram](private-function-diagram.jpg)

### Azure Function

The Azure Function app provisioned in this sample uses an [Azure Functions Premium plan](https://docs.microsoft.com/azure/azure-functions/functions-premium-plan#features).  The Premium plan is used to enable virtual network integration.  Virtual network integration is significant in this sample as the storage accounts used by the function app can only be accessed via private endpoints within the virtual network.

There are a few important details about the configuration of the function:

- Virtual network trigger support must be enabled in order for the function to trigger based on resources using a private endpoint
- In order to make [calls to a resource using a private endpoint](https://docs.microsoft.com/azure/azure-functions/functions-networking-options#azure-dns-private-zones), it is necessary to integrate with Azure DNS Private Zones. Therefore, it is necessary to configure the app to use a specific Azure DNS server, and also route all network traffic into the virtual network.  This is accomplished by setting the following application settings:
  - _WEBSITE_DNS_SERVER_ - 168.63.129.16
  - _WEBSITE_VNET_ROUTE_ALL_ - 1

The function is configured to [run from a deployment package](https://docs.microsoft.com/azure/azure-functions/run-functions-from-deployment-package).  As such, the package is persisted in an Azure File share referenced by the [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) application setting.

### Azure Storage accounts

There are four Azure Storage accounts used in this sample:

- two storage accounts use a private endpoint
  - a storage account used by the Azure Functions runtime for metadata (as referenced by the [AzureWebJobsStorage](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#azurewebjobsstorage) setting).
  - a storage account with a queue
- one storage account with no virtual network restrictions (indicated by the [WEBSITE_CONTENTAZUREFILECONNECTIONSTRING](https://docs.microsoft.com/azure/azure-functions/functions-app-settings#website_contentazurefileconnectionstring) setting) will contain the application code.
- one storage account used by the VM for diagnostics

### Azure CosmosDB

Azure CosmosDB is used to persist the data processed by the Azure Function.  An Azure Function output binding is used for writing the data to the configured database and collection.

A [private endpoint is created and configured for use with CosmosDB](https://docs.microsoft.com/azure/cosmos-db/how-to-configure-private-endpoints).

### Azure VM and Bastion

An Azure VM is created as a way to access the Azure resources from within the virtual network.  The VM has no public IP address nor port access (e.g. RDP).  [Azure Bastion](https://docs.microsoft.com/azure/bastion/bastion-overview) is used to connect to the VM.

The included ARM template configures the VM to shut down each evening at 7pm Eastern.  This is done as a cost-savings measure.

### Virtual Network

Azure resources in this sample either integrate with or are placed within a virtual network. The use of private endpoints keeps network traffic contained with the virtual network.

The sample uses four subnets:

- Subnet for Azure Function virtual network integration.  This subnet is delegated to the function.
- Subnet for private endpoints.  Private IP addresses are allocated from this subnet.
- Subnet for the virtual machine.
- Subnet for the Azure Bastion host.

### Private Endpoints

[Azure Private Endpoints](https://docs.microsoft.com/azure/private-link/private-endpoint-overview) are used to connect to specific Azure resources using a private IP address.  This ensures that network traffic remains within the designated virtual network, and access is available only for specific resources.  This sample configures private endpoints for the following Azure resources:

- [CosmosDB](https://docs.microsoft.com/azure/cosmos-db/how-to-configure-private-endpoints)
- [Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-private-endpoints)
  - Azure File storage
  - Azure Blob storage
  - Azure Queue storage
  - Azure Table storage
  
### Private DNS Zones

Using a private endpoint to connect to Azure resources means connecting to a private IP address instead of the public endpoint.  Existing Azure services are configured to use existing DNS to connect to the public endpoint.  The DNS configuration will need to be overridden to connect to the private endpoint.

A private DNS zone will be created for each Azure resource configured with a private endpoint.  A DNS A record is created for each private IP address associated with the private endpoint. 

The following DNS zones are created in this sample:

- privatelink.queue.core.windows.net
- privatelink.blob.core.windows.net
- privatelink.table.core.windows.net
- privatelink.file.core.windows.net
- privatelink.documents.azure.com

### Application Insights

[Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview) is used to [monitor the Azure Function](https://docs.microsoft.com/azure/azure-functions/functions-monitoring).

#### Thank you

Credit to Pasi Huuhka [@DrBushyTop](https://twitter.com/DrBushyTop) and the post at https://www.huuhka.net/automating-azure-private-link-storage-private-endpoints/ for the information on using ARM templates to get the IP addresses for the private DNS A records.
