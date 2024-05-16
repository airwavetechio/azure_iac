param vnetName string
param subnetName string
param properties object

// Because it's nested, you have to define the root resource
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

/// This one updated the existing subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = {
  name: subnetName
  parent: vnet
  properties: properties
}
