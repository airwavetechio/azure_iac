@description('Azure Region the resource group will be created in.')
param location string
param sku string
param tags object

@description('Used to generate the resource name.')
param appName string
param env string
param locationShorthand string
param appNameSuffix string = '${appName}-${env}-${locationShorthand}'

@description('A combined name to comply with the Team Rubicon naming convention')
var appServicePlanName = 'asp-${appNameSuffix}'

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  tags: tags
  location: location
  /// Windows
  sku: {
    name: sku
  }
}

output appServicePlanID string = appServicePlan.id
