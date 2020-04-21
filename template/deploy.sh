#!/bin/bash

#az login
#az account set -s 


resourceGroupName="function-private-storage-demo-scus-10"
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


# Get Azure Storage Private Endpoint data
echo "Getting Azure Storage queue private endpoint . . ."
storagePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointNetworkInterface.value --output tsv)
echo "Private storage queue NIC is $storagePrivateNic"


if [[ ! -z $storagePrivateNic ]]; then

    # Get the IP address
    echo "Getting Azure Storage queue private IP address . . ."
    storagePrivateIpAddress=$(az resource show --ids $storagePrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $storagePrivateIpAddress

    # # Get the DNS record
    echo "Getting private storage DNS record . . ."
    storagePrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateDNSRecordName.value --output tsv)

    # Deploy private zone for storage
    echo "Deploying private DNS zone records for storage . . . "
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$storagePrivateDnsRecord IPAddress=$storagePrivateIpAddress

fi

# Get Azure Cosmos DB Private Endpoint data
cosmosDbPrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointCosmosDbNetworkInterface.value --output tsv)
echo "CosmosDB private NIC is" $cosmosDbPrivateNic

if [[ ! -z $cosmosDbPrivateNic ]]; then

    # Get the IP address
    echo "Getting CosmosDB private IP address . . ."
    cosmosDbPrivateIpAddress=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress --output tsv)
    echo $cosmosDbPrivateIpAddress

    echo "Getting CosmosDB private member name . . . "
    cosmosDbPrivateMemberName=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[0].properties.privateLinkConnectionProperties.requiredMemberName --output tsv)


     echo "Getting second CosmosDB private IP address . . ."
    cosmosDbPrivateIpAddress2=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[1].properties.privateIPAddress --output tsv)
    echo $cosmosDbPrivateIpAddress2

    echo "Getting second CosmosDB private member name . . . "
    cosmosDbPrivateMemberName2=$(az resource show --ids $cosmosDbPrivateNic --query properties.ipConfigurations[1].properties.privateLinkConnectionProperties.requiredMemberName --output tsv)


    # Get the DNS record
    echo "Getting CosmosDB private DNS record . . ."
    cosmosDbPrivateDnsRecord=$(az deployment group show --name $deploymentName --query properties.outputs.privateCosmosDbDNSRecordName.value --output tsv)

## FIX UP THE HARD CODED BELOW

    # Deploy private zone for Cosmos DB
    echo "Deploying private DNS zone record for CosmosDB . . ."
    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName=$cosmosDbPrivateDnsRecord IPAddress=$cosmosDbPrivateIpAddress

    az deployment group create --template-file PrivateZoneRecords_template.json --parameters DNSRecordName='privatelink.documents.azure.com/'$cosmosDbPrivateMemberName2 IPAddress=$cosmosDbPrivateIpAddress2
fi
