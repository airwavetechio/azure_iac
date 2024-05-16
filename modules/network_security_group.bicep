param nsgName string
param location string
param tags object
param securityRules array = [
  // Default example to show structure
  // {
  //   name: 'string'
  //   properties: {
  //     access: 'string'
  //     description: 'string'
  //     destinationAddressPrefix: 'string'
  //     destinationAddressPrefixes: [
  //       'string'
  //     ]
  //     destinationApplicationSecurityGroups: [
  //       {
  //         id: 'string'
  //         location: 'string'
  //         properties: {}
  //         tags: {}
  //       }
  //     ]
  //     destinationPortRange: 'string'
  //     destinationPortRanges: [
  //       'string'
  //     ]
  //     direction: 'string'
  //     priority: int
  //     protocol: 'string'
  //     sourceAddressPrefix: 'string'
  //     sourceAddressPrefixes: [
  //       'string'
  //     ]
  //     sourceApplicationSecurityGroups: [
  //       {
  //         id: 'string'
  //         location: 'string'
  //         properties: {}
  //         tags: {}
  //       }
  //     ]
  //     sourcePortRange: 'string'
  //     sourcePortRanges: [
  //       'string'
  //     ]
  //   }
  //   type: 'string'
  // }
]

/// End of parameters

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: securityRules
  }
}

output nsgId string = nsg.id
