# Introduction 
This repo contains all the IAC code related to infrastructure. T

# Directory Structure

- **deployed_resources** - This is for resources deployed to existing resource groups or do not need a resource group when deploying.  
  - **Resource Group Name**
    - **resource_name**
      - main.bicep
      - README.md
      - parameters
        - env1.parameters.json
- **projects** - This is for application based resource groups. 
  - **Project Name A**
    - main.bicep
    - README.md
    - parameters
      - env1.parameters.json
      - env2.parameters.json
  - **Project Name B**
    - main.bicep
    - README.md
    - parameters
      - env1.parameters.json
      - env2.parameters.json
- **modules** - This is where the reusable BICEP code lives. 


# Develop
Please follow the `How to` section in BICEP guide https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/ 
## Linting

Before deploying the infrastructure, it's recommended to lint the Bicep files to ensure they adhere to the coding standards. Use the following commands to perform the linting:

```
az bicep build --file main.bicep
```

# How to apply
## Select the right subscription
Use the `az` cli tool to login, and set the subscription you want to connect. You use `az account list` to find out the uuid of the subscription you want to work in. 
```
 az login
 az account list --output table
 az account set --subscription <uuid>
```

| Name                  | CloudName  | SubscriptionId                       | TenantId                             | State   | IsDefault |
| --------------------- | ---------- | ------------------------------------ | ------------------------------------ | ------- | --------- |
| TRTech_dev            | AzureCloud | <dev subscription id> | <tenant id> | Enabled | True      |
| staging             | AzureCloud | <staging subscription id> | <tenant id> | Enabled | False     |
| prod           | AzureCloud | <prod subscription id> | <tenant id> | Enabled | False     |

## Deploying
The following is an example of how to apply resources to an existing Resource Group on your local dev machine. Different types of resources use different commands. Search for the latest documentation on `az bicep`. 

  ```
  az deployment group create \
  --name <SomeDescriptiveName> \
  --resource-group <Resource Group Name> \
  --template-file main.bicep \
  --parameters parameters.json
  ``` 


## azure-pipelines.yml
Depending on the branch you are pushing commits to, a `stage` will trigger. Each `stage` represents an environment with its own set of variables that are in the `<env>.variables.yml` files. 

### Stages
* `Development`: This stage is triggered by branches that contain specific keywords (e.g., TICKET-001-name) or the develop branch. It uses the dev.variables.yml for its variables.
* `Staging`: This stage is triggered by the main branch. It uses the staging.variables.yml for its variables.
* `Production`: This stage is triggered by branches that start with release/. It uses the prod.variables.yml for its variables.

#### Jobs
Each `stage` has a `job`. A `job` is just another group, but in our case, this job for all 3 stages will run the template file `deployment-template.yml`. <TODO Need to create a README for that to make it easier.>

The variable file provide will populate parmaters for that template, so we get some resuabilty, without a lot of copy/paste code everywhere. 


