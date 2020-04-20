#!/bin/bash -v

#az login
#az account set -s 


resourceGroupName="function-private-storage-demo-scus-script-2"
location="southcentralus"
now=`date +%Y%m%d-%H%M%S`
deploymentName="azuredeploy-$now"


az group create --name $resourceGroupName --location southcentralus

az configure --defaults group=$resourceGroupName location=$location

# az deployment group validate --template-file azuredeploy.json --parameters azuredeploy.parameters.json --debug

az deployment group create --template-file azuredeploy.json --parameters azuredeploy.parameters.json --name $deploymentName

storagePrivateNic=$(az deployment group show -g $resourceGroupName --name $deploymentName --query properties.outputs.privateEndpointNetworkInterface.value)
echo $storagePrivateNic

# Get the IP address
storagePrivateIpAddress=$(az resource show --ids $storagePrivateNic --query properties.ipConfigurations[0].properties.privateIPAddress)
echo $storagePrivateIpAddress

# # Get the DNS record
storagePrivateDnsRecord=$(az deployment group show -g $resourceGroupName --name $deploymentName --query properties.outputs.privateDNSRecordName.value)

# az deployment group create -g function-private-storage-demo-scus --template-file PrivateZoneRecords_template.json --parameters DNSRecordName='[PRIVATE DNS NAME]' IPAddress='[PRIVATE IP ADDRESS]'