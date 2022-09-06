$SUBSCRIPTION_ID = '<your-subscription-id>'
$KEYVAULT_NAME="<your-key-vault-name>"

# login as a user and set the appropriate subscription ID
az login
az account set -s $SUBSCRIPTION_ID

#Add a secret to your Keyvault:
az keyvault secret set --vault-name $KEYVAULT_NAME --name secret1 --value "My Top Secret Value!"

kubectl apply -f .\manifests\secrets-provider-class-deploy.yml

#To validate, once the pod is started, you should see the new mounted content at the volume path specified in your deployment yaml.

## show secrets held in secrets-store
kubectl exec deployment/web-deploy -- ls /mnt/secrets-store/
## print a test secret held in secrets-store
kubectl exec deployment/web-deploy -- cat /mnt/secrets-store/secret1