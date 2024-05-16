@description('Location for all resources.')
param location string = resourceGroup().location
param tags object

@description('Used to generate the resource name.')
param appName string
param env string
param locationShorthand string

@description('A combined name to comply with the Team Rubicon naming convention')
@minLength(3)
#disable-next-line BCP334
param storageAccountName string = 'sa${appName}${env}${locationShorthand}'

@description('The access tier of the storage account')
param accessTier string = 'Hot'
@description('Array of file share objects, each including a name and an access tier.')
param fileSharesData array = [
  // Default example to show structure
  //{
  //  name: 'backups'
  //  accessTier: 'Cool'
  // }
]

///////// End of parameters

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
    //    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
    allowCrossTenantReplication: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: accessTier
  }
}

resource defaultFileService 'Microsoft.Storage/storageAccounts/fileServices@2021-02-01' = {
  parent: storageAccount
  name: 'default'
}

resource shares 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01' = [
  for fileShare in fileSharesData: if (fileShare.name != '') {
    parent: defaultFileService
    name: fileShare.name
    properties: {
      accessTier: fileShare.accessTier
    }
  }
]

output storageAccountID string = storageAccount.id
output storageAccountAPIVersion string = storageAccount.apiVersion
