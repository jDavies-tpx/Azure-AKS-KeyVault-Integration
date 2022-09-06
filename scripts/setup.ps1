$LOCATION = '<your-location>'
$RESOURCE_GROUP = '<your-resource-group-name>'
$STORAGE_ACCOUNT_NAME = '<your-storage-account-name>'
$STORAGE_CONTAINER_NAME = '<your-container-name>'
$SUBSCRIPTION_ID = '<your-subscription-id>'
$SERVICE_PRINCIPAL_NAME = '<your-service-principal-name>'

# Create Resource Group
az group create -n $RESOURCE_GROUP -l $LOCATION
 
# Create Storage Account
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP -l $LOCATION --sku Standard_LRS
 
# Create Storage Account Container
az storage container create -n $STORAGE_CONTAINER_NAME 

# Create Service Principal scoped to resource group
az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --role="Contributor" --scopes="/subscriptions/$($SUBSCRIPTION_ID)/resourceGroups/$($RESOURCE_GROUP)"
