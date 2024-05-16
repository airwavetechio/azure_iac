targetScope = 'subscription'

@description('Used to generate the resource name.')
param appName string
param tags object
param env string
param locationShorthand string

@description('A combined name to comply with the Team Rubicon naming convention')
param rgName string = 'rg_${appName}_${env}_${locationShorthand}'

@description('Azure Region the resource group will be created in.')
param location string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: tags
}

output resourceGroupName string = resourceGroup.name
