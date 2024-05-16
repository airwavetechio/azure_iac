https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/create-resource-group

Here's how we deployed the CloudOps resource group. 

* Dry Run
```
az deployment group what-if --name apimanagement --resource-group <resource group id> --mode incremental --template-file main.bicep --parameters parameters/dev.parameters.json
```

* Dev
  ```
   az account set --subscription <dev subscription id>
  az deployment group  create --name apimanagement --resource-group <resource group id> --mode incremental --template-file main.bicep --parameters parameters/dev.parameters.json
    ```


# Notes
* You have to manuall create the Virtual link in the Private DNS to TR_CORE
* You have to manually disable the public access using the MGMT API
  ```
  curl --location --request PUT 'https://management.azure.com/subscriptions/<dev subscription id>/resourceGroups/<resource group id>/providers/Microsoft.ApiManagement/service/<api mgmt name>?api-version=2021-08-01' --header 'Authorization: Bearer <bearer token>' --header 'Content-Type: application/json' --data-raw '{
    "location": "westus",
    "sku": {
        "name": "Developer",
        "capacity": 1
    },
      "properties": {
        "publicNetworkAccess": "Disabled",
        "publisherEmail": "tony@airwavetech.io",
        "publisherName": "Tony Chong"
      }
    }'
```