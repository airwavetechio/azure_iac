param location string = resourceGroup().location

@description('Used to generate the resource name.')
param env string
param tags object

//VMSS
@description('Use to place the VMSS in an existing VNET and subnet')
param vmssVnetResourceGroupName string
param vmssVnetName string
param vmssSubnetName string
param appName string

module vmss '../../../modules/vmss.bicep' = {
  name: appName
  params: {
    // Should use key vault but need to centralize it first
    adminPasswordOrKey: 'testPassword1234'
    env: env
    location: location
    vnetName: vmssVnetName
    vnetResourceGroupName: vmssVnetResourceGroupName
    subnetName: vmssSubnetName
    tags: tags
    imageOffer: 'WindowsServer'
    imagePublisher: 'MicrosoftWindowsServer'
    imageSKU: '2022-datacenter-core-smalldisk-g2'
    imageVersion: 'latest'
    singlePlacementGroup: true
  }
}
