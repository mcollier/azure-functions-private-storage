#!/bin/bash

#az login
#az account set -s 


resourceGroupName="function-private-storage-401"
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
storagePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateStorageQueueEndpointNetworkInterface.value --output tsv)
echo "Private storage queue NIC is $storagePrivateNic"

if [[ ! -z $storagePrivateNic ]]; then

    storageQueuePrivateDnsZoneName=$(az deployment group show --name $deploymentName --query properties.outputs.storageQueuePrivateDnsZoneName.value --output tsv)

    if [[ ! -z $storageQueuePrivateDnsZoneName ]]; then

        az deployment group create --template-file PrivateLinkIPConfigParser.json --parameters nicId=$storagePrivateNic privateDnsZoneName=$storageQueuePrivateDnsZoneName dnsEntriesHandlerTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries_handler.json' dnsEntriesTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries.json' --name "PrivateLinkIpConfig-Storage-Queue-$now"
    fi
fi

echo "Getting Azure web jobs storage queue private endpoint . . ."
webJobsStorageQueuePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsQueueStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage queue NIC is $webJobsStorageQueuePrivateNic"

if [[ ! -z $webJobsStorageQueuePrivateNic ]]; then

    if [[ ! -z $storageQueuePrivateDnsZoneName ]]; then

        az deployment group create --template-file PrivateLinkIPConfigParser.json --parameters nicId=$webJobsStorageQueuePrivateNic privateDnsZoneName=$storageQueuePrivateDnsZoneName dnsEntriesHandlerTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries_handler.json' dnsEntriesTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries.json' --name "PrivateLinkIpConfig-WebJobsStorage-Queue-$now"
    fi
fi

echo "Getting Azure web jobs storage table private endpoint . . ."
webJobsStorageTablePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsTableStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage table NIC is $webJobsStorageTablePrivateNic"

if [[ ! -z $webJobsStorageTablePrivateNic ]]; then
    storageTablePrivateDnsZoneName=$(az deployment group show --name $deploymentName --query properties.outputs.storageTablePrivateDnsZoneName.value --output tsv)

    if [[ ! -z $storageTablePrivateDnsZoneName ]]; then

        az deployment group create --template-file PrivateLinkIPConfigParser.json --parameters nicId=$webJobsStorageTablePrivateNic privateDnsZoneName=$storageTablePrivateDnsZoneName dnsEntriesHandlerTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries_handler.json' dnsEntriesTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries.json' --name "PrivateLinkIpConfig-WebJobsStorage-Table-$now"
    fi
fi

echo "Getting Azure web jobs storage blob private endpoint . . ."
webJobsStorageBlobPrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsBlobStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage blob NIC is $webJobsStorageBlobPrivateNic"

if [[ ! -z $webJobsStorageBlobPrivateNic ]]; then
    storageBlobPrivateDnsZoneName=$(az deployment group show --name $deploymentName --query properties.outputs.storageBlobPrivateDnsZoneName.value --output tsv)

    if [[ ! -z $storageBlobPrivateDnsZoneName ]]; then

        az deployment group create --template-file PrivateLinkIPConfigParser.json --parameters nicId=$webJobsStorageBlobPrivateNic privateDnsZoneName=$storageBlobPrivateDnsZoneName dnsEntriesHandlerTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries_handler.json' dnsEntriesTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries.json' --name "PrivateLinkIpConfig-WebJobsStorage-Blob-$now"
    fi
fi

echo "Getting Azure web jobs storage file private endpoint . . ."
webJobsStorageFilePrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointWebJobsFileStorageNameNetworkInterface.value --output tsv)
echo "Private web jobs storage file NIC is $webJobsStorageFilePrivateNic"

if [[ ! -z $webJobsStorageFilePrivateNic ]]; then
    storageFilePrivateDnsZoneName=$(az deployment group show --name $deploymentName --query properties.outputs.storageBlobPrivateDnsZoneName.value --output tsv)

    if [[ ! -z $storageFilePrivateDnsZoneName ]]; then

        az deployment group create --template-file PrivateLinkIPConfigParser.json --parameters nicId=$webJobsStorageFilePrivateNic privateDnsZoneName=$storageFilePrivateDnsZoneName dnsEntriesHandlerTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries_handler.json' dnsEntriesTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries.json' --name "PrivateLinkIpConfig-WebJobsStorage-File-$now"
    fi
fi

# ----- Begin web jobs storage config -----

# --- End web jobs storage config


# Get Azure Cosmos DB Private Endpoint data
echo "Getting CosmosDB private endpoint . . ."
cosmosDbPrivateNic=$(az deployment group show --name $deploymentName --query properties.outputs.privateEndpointCosmosDbNetworkInterface.value --output tsv)
echo "CosmosDB private NIC is" $cosmosDbPrivateNic

if [[ ! -z $cosmosDbPrivateNic ]]; then

    echo "Getting CosmosDB private DNS record . . ."
    cosmosDbPrivateDnsZoneName=$(az deployment group show --name $deploymentName --query properties.outputs.privateCosmosDbDnsZoneName.value --output tsv)

    if [[ ! -z $cosmosDbPrivateDnsZoneName ]]; then

        az deployment group create --template-file PrivateLinkIPConfigParser.json --parameters nicId=$cosmosDbPrivateNic privateDnsZoneName=$cosmosDbPrivateDnsZoneName dnsEntriesHandlerTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries_handler.json' dnsEntriesTemplateUri='https://raw.githubusercontent.com/DrBushyTop/ARMTemplates/master/PrivateLink/privatelink_dnsentries.json' --name "PrivateLinkIpConfig-CosmosDb-$now"
    fi

fi
