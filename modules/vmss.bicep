@description('Size of VMs in the VM Scale Set.')
param vmSku string = 'Standard_D2s_v3'

@description('The name of the environment')
param env string

@description('Tags for each resource')
param tags object

@description('Windows naming limitations for VMSS are short')
@maxLength(9)
param vmssName string = 'vmss-${env}'

@description('Number of VM instances (100 or less).')
@minValue(1)
@maxValue(100)
param instanceCount int = 1

@description('Admin username on all VMs.')
param adminUsername string = 'tradmin'

@description('Name of the resourceGroup for the existing virtual network to deploy the scale set into.')
param vnetResourceGroupName string

@description('vName of the existing virtual network to deploy the scale set into.')
param vnetName string

@description('Name of the existing subnet to deploy the scale set into.')
param subnetName string

// @description('Type of authentication to use on the Virtual Machine. SSH key is recommended.')
// @allowed([
//   'sshPublicKey'
//   'password'
// ])
// param authenticationType string = 'sshPublicKey'

@description('SSH Key or password for the Virtual Machine. SSH key is recommended.')
@secure()
param adminPasswordOrKey string

@description('Location for all resources.')
param location string

param singlePlacementGroup bool
param imagePublisher string
param imageOffer string
param imageSKU string
param imageVersion string

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2019-12-01' = {
  name: vmssName
  location: location
  sku: {
    name: vmSku
    capacity: instanceCount
  }
  tags: tags
  properties: {
    singlePlacementGroup: singlePlacementGroup
    overprovision: false
    upgradePolicy: {
      mode: 'Manual'
    }
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
        }
        imageReference: {
          publisher: imagePublisher
          offer: imageOffer
          sku: imageSKU
          version: imageVersion
        }
      }
      osProfile: {
        computerNamePrefix: vmssName
        adminUsername: adminUsername
        adminPassword: adminPasswordOrKey
        windowsConfiguration: {
          provisionVMAgent: true
          enableAutomaticUpdates: true
        }

        // // linuxConfiguration: {
        // //   disablePasswordAuthentication: true
        // //   ssh: {
        // //     publicKeys: [
        // //       {
        // //         path: '/home/${adminUsername}/.ssh/authorized_keys'
        // //         keyData: adminPasswordOrKey
        // //       }
        // //     ]
        // //   }
        // }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              // networkSecurityGroup: {
              //   id: nsg.id
              // }
              ipConfigurations: [
                {
                  name: 'ipconfig'
                  properties: {
                    subnet: {
                      id: resourceId(
                        vnetResourceGroupName,
                        'Microsoft.Network/virtualNetworks/subnets',
                        vnetName,
                        subnetName
                      )
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
