https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/create-resource-group

Here's how we deployed the CloudOps resource group. 

* Dry Run
  ```
  az deployment sub what-if --name projectB --location westus --template-file main.bicep --parameters parameters/dev.parameters.json --parameter appName='projectBtest'
  ```

* Dev
  ```
   az account set --subscription <dev subscription id>
   az deployment sub create --name projectB --location westus --template-file main.bicep --parameters parameters/dev.parameters.json
    ```

* STAGING
  ```
   az account set --subscription <staging subscription id>
   az deployment sub create --name projectb --location westus --template-file main.bicep --parameters parameters/staging.parameters.json
  ```

* Prod
  ```
   az account set --subscription <prod subscription id>
   az deployment sub create --name projectb --location westus --template-file main.bicep --parameters parameters/prod.parameters.json
  ```