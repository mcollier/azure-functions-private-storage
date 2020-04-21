#!/bin/bash

#az login
#az account set -s 


resourceGroupName="function-private-storage-demo-scus-201"
location="southcentralus"
now=`date +%Y%m%d-%H%M%S`
deploymentName="azuredeploy-$now"

echo "Creating resource group '$resourceGroupName' in region '$location' . . ."
az group create --name $resourceGroupName --location southcentralus

echo "Setting defaults ...."
az configure --defaults group=$resourceGroupName location=$location

# az deployment group validate --template-file azuredeploy.json --parameters azuredeploy.parameters.json --debug

echo "Deploying main template . . ."
az deployment group create --template-file azuredeploy.json --parameters azuredeploy.parameters.json --name $deploymentName


# TODO: THERE HAS TO BE A BETTER WAY TO GET THE IP ADDRESS FOR EACH OF THE PRIVATE ENDPOINT NICS AND SET THE DNS A RECORDS!!!


# Get Azure Storage Private Endpoint data
echo "Getting Azure Storage queue private endpoint . . ."
storagePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateStorageQueueEndpointNetworkInterface.value --output tsv)
echo "Private storage queue NIC is $storagePrivateNic"

if [[ ! -z $storagePrivateNic ]]; then

    # Get the IP address
    echo "Getting Azure Storage queue private IP address . . ."
    storagePrivateIpAddress=$(az resource show --ids $storagePrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $storagePrivateIpAddress

    # # Get the DNS record
    echo "Getting private storage DNS record . . ."
    storagePrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateStorageDNSRecordName.value --output tsv)

    # Deploy private zone for storage
    echo "Deploying private DNS zone records for storage . . . "
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$storagePrivateDnsRecord IPAddress=$storagePrivateIpAddress --name "PrivateZoneRecords-Storage-$now"
fi

# ----- Begin web jobs storage config -----

# Get Azure Web Jobs Storage Queue Private Endpoint data
echo "Getting Azure web jobs storage queue private endpoint . . ."
webJobsStorageQueuePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsQueueStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage queue NIC is $webJobsStorageQueuePrivateNic"

if [[ ! -z $webJobsStorageQueuePrivateNic ]]; then

    # Get the IP address
    echo "Getting Azure web jobs storage queue private IP address . . ."
    webJobsStorageQueuePrivateIpAddress=$(az resource show --ids $webJobsStorageQueuePrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $webJobsStorageQueuePrivateIpAddress

    # # Get the DNS record
    echo "Getting private web jobs storage queue DNS record . . ."
    webJobsStorageQueuePrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateWebJobsStorageQueueDNSRecordName.value --output tsv)

    # Deploy private zone for storage
    echo "Deploying private DNS zone records for web jobs storage queue . . . "
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$webJobsStorageQueuePrivateDnsRecord IPAddress=$webJobsStorageQueuePrivateIpAddress --name "PrivateZoneRecords-WJSA-Queue-$now"
fi

# Get Azure Web Jobs Storage Table Private Endpoint data
echo "Getting Azure web jobs storage table private endpoint . . ."
webJobsStorageTablePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsTableStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage table NIC is $webJobsStorageTablePrivateNic"

if [[ ! -z $webJobsStorageTablePrivateNic ]]; then

    # Get the IP address
    echo "Getting Azure web jobs storage table private IP address . . ."
    webJobsStorageTablePrivateIpAddress=$(az resource show --ids $webJobsStorageTablePrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $webJobsStorageTablePrivateIpAddress

    # # Get the DNS record
    echo "Getting private web jobs storage table DNS record . . ."
    webJobsStorageTablePrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateWebJobsStorageTableDNSRecordName.value --output tsv)

    # Deploy private zone for storage
    echo "Deploying private DNS zone records for web jobs storage table . . . "
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$webJobsStorageTablePrivateDnsRecord IPAddress=$webJobsStorageTablePrivateIpAddress --name "PrivateZoneRecords-WJSA-Table-$now"
fi

# Get Azure Web Jobs Storage Blob Private Endpoint data
echo "Getting Azure web jobs storage blob private endpoint . . ."
webJobsStorageBlobPrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsBlobStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage blob NIC is $webJobsStorageBlobPrivateNic"

if [[ ! -z $webJobsStorageBlobPrivateNic ]]; then

    # Get the IP address
    echo "Getting Azure web jobs storage blob private IP address . . ."
    webJobsStorageBlobPrivateIpAddress=$(az resource show --ids $webJobsStorageBlobPrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $webJobsStorageBlobPrivateIpAddress

    # # Get the DNS record
    echo "Getting private web jobs storage blob DNS record . . ."
    webJobsStorageBlobPrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateWebJobsStorageBlobDNSRecordName.value --output tsv)

    # Deploy private zone for storage
    echo "Deploying private DNS zone records for web jobs storage blob . . . "
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$webJobsStorageBlobPrivateDnsRecord IPAddress=$webJobsStorageBlobPrivateIpAddress --name "PrivateZoneRecords-WJSA-Blob-$now"
fi

# Get Azure Web Jobs Storage Table Private Endpoint data
echo "Getting Azure web jobs storage file private endpoint . . ."
webJobsStorageFilePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsFileStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage file NIC is $webJobsStorageFilePrivateNic"

if [[ ! -z $webJobsStorageFilePrivateNic ]]; then

    # Get the IP address
    echo "Getting Azure web jobs storage file private IP address . . ."
    webJobsStorageFilePrivateIpAddress=$(az resource show --ids $webJobsStorageFilePrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $webJobsStorageFilePrivateIpAddress

    # # Get the DNS record
    echo "Getting private web jobs storage file DNS record . . ."
    webJobsStorageFilePrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateWebJobsStorageFileDNSRecordName.value --output tsv)

    # Deploy private zone for storage
    echo "Deploying private DNS zone records for web jobs storage file . . . "
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$webJobsStorageFilePrivateDnsRecord IPAddress=$webJobsStorageFilePrivateIpAddress --name "PrivateZoneRecords-WJSA-File-$now"
fi

#### --- End web jobs storage config


# Get Azure Cosmos DB Private Endpoint data
echo "Getting CosmosDB private endpoint . . ."
cosmosDbPrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointCosmosDbNetworkInterface.value --output tsv)
echo "CosmosDB private NIC is" $cosmosDbPrivateNic

if [[ ! -z $cosmosDbPrivateNic ]]; then

    # Get the IP address
    echo "Getting first CosmosDB private IP address . . ."
    cosmosDbPrivateIpAddress=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $cosmosDbPrivateIpAddress

    echo "Getting first CosmosDB private member name . . . "
    cosmosDbPrivateMemberName=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[0].properties.privateLinkConnectionProperties.requiredMemberName --output tsv)


     echo "Getting second CosmosDB private IP address . . ."
    cosmosDbPrivateIpAddress2=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[1].properties.privateIPAddress --output tsv)
    echo $cosmosDbPrivateIpAddress2

    echo "Getting second CosmosDB private member name . . . "
    cosmosDbPrivateMemberName2=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[1].properties.privateLinkConnectionProperties.requiredMemberName --output tsv)


    # Get the DNS record
    echo "Getting CosmosDB private DNS record . . ."
    cosmosDbPrivateDnsZoneName=$(az deployment group show --name $deploymentName --query properties.outputs.privateCosmosDbDnsZoneName.value --output tsv)

    # Deploy private zone for Cosmos DB
    echo "Deploying private DNS zone record for CosmosDB . . ."
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$cosmosDbPrivateDnsZoneName'/'$cosmosDbPrivateMemberName IPAddress=$cosmosDbPrivateIpAddress --name "PrivateZoneRecords-Cosmos-$now"

    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$cosmosDbPrivateDnsZoneName'/'$cosmosDbPrivateMemberName2 IPAddress=$cosmosDbPrivateIpAddress2 --name "PrivateZoneRecords-Cosmos-2-$now"
fi
