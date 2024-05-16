targetScope = 'subscription'
param location string = deployment().location

@description('Used to generate the resource name.')
param env string = 'test'
param locationShorthand string = 'wus'

@description('The name of the app, to be reused everywhere')
param appName string = 'projectB'

param tags object = {
  Owner: 'tony@airwavetech.io'
  'Created By': 'tony@airwavetech.io'
  'Application Name': appName
  Environment: env
  Description: 'Project B'
  'Business Unit': 'Cloud Ops'
  Stakeholder: 'tony@airwavetech.io'
  'Tech Team': 'Cloud Ops & Full Stacks '
  'Created Using': 'BICEP'
}

// Resource Group
@description('A combined name to comply with the Team Rubicon naming convention')
var rgName = 'rg_${appName}_${env}_${locationShorthand}'

/// App Service 
param appServicePlanSKU string = 'F1' // This will not succeed because you can't have private endpoints
param appServicesData array = [
  {
    name: '${appName}-api'
    kind: 'webApp'
    webConfig: {
      enabled: false
    }
  }
  {
    name: '${appName}-web'
    kind: 'webApp'
    webConfig: {
      enabled: true
      virtualPath: '/'
      physicalPath: 'site\\wwwroot\\browser'
    }
  }
]
/// End of params

// Must be a resource, can't use the existing module
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: tags
}

module storageAcct '../../modules/storage_accounts_w_pe.bicep' = {
  name: 'storageAcct'
  scope: az.resourceGroup(resourceGroup.name)
  params: {
    tags: tags
    location: location
    env: env
    locationShorthand: locationShorthand
    appName: appName
    privateDnsZonesStorageID: '/subscriptions/<dev subscription id>/resourceGroups/<resource group id>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.${environment().suffixes.storage}'
    subnetStorageID: '/subscriptions/<dev subscription id>/resourceGroups/<resource group id>/providers/Microsoft.Network/virtualNetworks/<vnet name>/subnets/<storage account subnet ID>'
  }
}

module appServicePlan '../../modules/app_service_plan.bicep' = {
  name: 'asp'
  params: {
    appName: appName
    env: env
    location: location
    locationShorthand: locationShorthand
    sku: appServicePlanSKU
    tags: tags
  }
  scope: resourceGroup
}

module appServices '../../modules/app_service_w_pe.bicep' = {
  name: 'appServices'
  params: {
    location: location
    appServicePlanID: appServicePlan.outputs.appServicePlanID
    env: env
    locationShorthand: locationShorthand
    appServicesData: appServicesData
    privateDnsZonesWebAppID: '/subscriptions/<dev subscription id>/resourceGroups/<resource group id>/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net'
    subnetWebAppID: '/subscriptions/<dev subscription id>/resourceGroups/<resource group id>/providers/Microsoft.Network/virtualNetworks/<vnet name>/subnets/sn_webapp_dev_wus'
    tags: tags
  }
  scope: resourceGroup
}
