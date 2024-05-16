param tags object
param privateDnsZoneName string
param vnetAppSvcId string
//@description('Used to describe the name of the VNET ID for core')
//param vnetCoreId string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
  properties: {}
}

resource vnetLinkAppSvcs 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'linktoappsvcs'
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetAppSvcId
    }
  }
}

//You must deploy the link to core in the private DNS manually due to permissions issues
// resource vnetLinkCore 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZone
//   name: 'linktocore'
//   location: 'global'
//   tags: tags
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnetCoreId
//     }
//   }
// }

output privateDnsZoneId string = privateDnsZone.id
