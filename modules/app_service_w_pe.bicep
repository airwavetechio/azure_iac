@description('Azure Region the resource group will be created in.')
param location string
param appServicePlanID string
param tags object

@description('Used to generate the resource name.')
param env string
param locationShorthand string

@description('An array of objects used to define the number of web apps')
param appServicesData array = [
  //  {
  //   name: '${appName}-web'
  //   kind: 'webApp'
  //   webConfig: {
  //     enabled: true
  //     virtualPath: '/'
  //     physicalPath: 'site\\wwwroot\\browser'
  //   }
  // }
]

param privateDnsZonesWebAppID string // Get confirmation from Gregg
param subnetWebAppID string // Get confirmation from Gregg

// End of parameters

resource appServices 'Microsoft.Web/sites@2022-03-01' = [
  for appService in appServicesData: {
    name: 'wa-${appService.name}-${env}-${locationShorthand}'
    location: location
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      serverFarmId: appServicePlanID
      httpsOnly: true
      siteConfig: appService.kind
    }
  }
]

resource appServicesConfigs 'Microsoft.Web/sites/config@2023-01-01' = [
  for (appService, index) in appServicesData: if (appService.webConfig.enabled == true) {
    name: '${appServices[index].name}/web'
    properties: {
      numberOfWorkers: 1
      defaultDocuments: [
        'index.html'
      ]
      virtualApplications: [
        {
          virtualPath: appService.webConfig.virtualPath
          physicalPath: appService.webConfig.physicalPath
          preloadEnabled: false
        }
      ]
    }
  }
]

resource privateEndpoints 'Microsoft.Network/privateEndpoints@2022-07-01' = [
  for (appService, index) in appServicesData: {
    name: 'pe-${appService.name}-${env}-${locationShorthand}'
    location: location
    tags: tags
    properties: {
      privateLinkServiceConnections: [
        {
          name: 'plsc-${appService.name}-${env}-${locationShorthand}'
          properties: {
            privateLinkServiceId: appServices[index].id
            groupIds: [
              'sites'
            ]
            privateLinkServiceConnectionState: {
              status: 'Approved'
              actionsRequired: 'None'
            }
          }
        }
      ]
      customNetworkInterfaceName: 'pe-${appService.name}-${env}-${locationShorthand}-nic'

      subnet: {
        id: subnetWebAppID
      }
    }
    dependsOn: [
      appServices[index]
    ]
  }
]

resource privateEndpointsDNS 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = [
  for (appService, index) in appServicesData: {
    parent: privateEndpoints[index]
    name: 'default-${appService.name}' // Ensure unique name for each DNS zone group
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'privatelink-azurewebsites-net-${appService.name}' // Ensure unique name for each config
          properties: {
            privateDnsZoneId: privateDnsZonesWebAppID
          }
        }
      ]
    }
  }
]
