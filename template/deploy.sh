#!/bin/bash

#az login
#az account set -s 


resourceGroupName="functions-private-endpoints-sample-4"
location="southcentralus"
now=`date +%Y%m%d-%H%M%S`
deploymentName="azuredeploy-$now"

echo "Creating resource group '$resourceGroupName' in region '$location' . . ."
az group create --name $resourceGroupName --location southcentralus

# echo "Validating the template . . ."
# az deployment group validate -g $resourceGroupName --template-file azuredeploy.json --parameters azuredeploy.parameters.json --debug

echo "Deploying main template . . ."
az deployment group create -g $resourceGroupName --template-file azuredeploy.json --parameters azuredeploy.parameters.json --name $deploymentName
