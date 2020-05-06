#!/bin/bash

#az login
#az account set -s 


resourceGroupName="function-private-storage-1002"
location="southcentralus"
now=`date +%Y%m%d-%H%M%S`
deploymentName="azuredeploy-$now"
dnsEntriesHandlerTemplateUri="https://raw.githubusercontent.com/mcollier/azure-functions-private-storage/master/template/PrivateLinkDnsEntriesHandler.json"
dnsEntriesTemplateUri="https://raw.githubusercontent.com/mcollier/azure-functions-private-storage/master/template/PrivateLinkDnsEntries.json"


echo "Creating resource group '$resourceGroupName' in region '$location' . . ."
az group create --name $resourceGroupName --location southcentralus

echo "Setting defaults ...."
az configure --defaults group=$resourceGroupName location=$location

# az deployment group validate --template-file azuredeploy.json --parameters azuredeploy.parameters.json --debug

echo "Deploying main template . . ."
az deployment group create --template-file azuredeploy.json --parameters azuredeploy.parameters.json --name $deploymentName
