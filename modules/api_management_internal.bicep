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
param subnetApiMgmtID string
param apiMgmtName string = 'apim-${appNameSuffix}'
param virtualNetworkType string

// API Mgmt NSG
param vnetName string
param vnetSubnetName string
//param vnetSubnetId string
param apiMgmtNSGName string
param apiMgmtNSGSecurityRules array

/// End of pameters

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
    publicNetworkAccess: 'false'
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: {
      subnetResourceId: subnetApiMgmtID
    }
    customProperties: customProperties
    // Not supported during service creation
    //publicNetworkAccess: 'Disabled'
  }
}

//Get the name
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: vnetSubnetName
  parent: vnet
}

module updateSubnet './nested/update_subnet.bicep' = {
  name: vnetSubnetName
  //parent: vnet
  params: {
    properties: {
      addressPrefix: subnet.properties.addressPrefix
      networkSecurityGroup: {
        id: apiMgmtNSG.outputs.nsgId
      }
    }
    subnetName: vnetSubnetName
    vnetName: vnetName
  }
}

output ApiMgmtSvcPrivateIp string = apiMgmt.properties.privateIPAddresses[0]
