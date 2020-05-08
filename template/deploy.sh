#!/bin/bash

#az login
az account set -s c68d7703-d6ed-46a5-b1f4-ac8fe4a81ac9


resourceGroupName="functions-private-endpoints-eastus"
location="eastus"
now=`date +%Y%m%d-%H%M%S`
deploymentName="azuredeploy-$now"

echo "Creating resource group '$resourceGroupName' in region '$location' . . ."
az group create --name $resourceGroupName --location $location

# echo "Validating the template . . ."
# az deployment group validate -g $resourceGroupName --template-file azuredeploy.json --parameters azuredeploy.parameters.json --debug

echo "Deploying main template . . ."
az deployment group create -g $resourceGroupName --template-file azuredeploy.json --parameters azuredeploy.parameters.json --name $deploymentName

