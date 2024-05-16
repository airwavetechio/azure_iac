@description('Azure Region the resource group will be created in.')
param location string
param tags object

@description('Used to generate the resource name.')
param appName string
param env string
param locationShorthand string

param zones array
param tier string
param capacity int
param adminEmail string
param organizationName string
param customProperties object
param appNameSuffix string = '${appName}-${env}-${locationShorthand}'
param privateEndpointName string = 'pe-${appNameSuffix}'
param subnetApiMgmtID string
param privateDnsZoneId string
param apiMgmtName string = 'apim-${appNameSuffix}'

// API Mgmt NSG
param apiMgmtNSGName string
param apiMgmtNSGSecurityRules array

module apiMgmtNSG './network_security_group.bicep' = {
  name: apiMgmtNSGName
  params: { securityRules: apiMgmtNSGSecurityRules, location: location, nsgName: apiMgmtNSGName, tags: tags }
}

resource apiMgmt 'Microsoft.ApiManagement/service@2023-05-01-preview' = {
  name: apiMgmtName
  location: location
  sku: {
    name: tier
    capacity: capacity
  }
  zones: zones
  tags: tags
  properties: {
    publisherEmail: adminEmail
    publisherName: organizationName
    customProperties: customProperties
    // Not supported during service creation
    //publicNetworkAccess: 'Disabled'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  location: location
  name: privateEndpointName

  properties: {
    privateLinkServiceConnections: [
      {
        name: 'plsc-${appNameSuffix}'
        properties: {
          privateLinkServiceId: apiMgmt.id
          groupIds: [
            'Gateway'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    customNetworkInterfaceName: '${privateEndpointName}-nic'

    subnet: {
      id: subnetApiMgmtID
    }
  }

  tags: tags
}

resource privateEndpointApiMgmtDNS 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-06-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(privateEndpoint.name, '.', '-')
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

module networkInterface '../modules/nested/get_pe_private_ip.bicep' = {
  name: 'nested'
  params: {
    nicName: last(split(privateEndpoint.properties.networkInterfaces[0].id, '/'))
  }
}

output privateEndpointID string = privateEndpoint.id
output privateEndpointName string = privateEndpoint.name
output privateEndpointPrivateIPAddress string = networkInterface.outputs.privateIPAddress
