param location string = resourceGroup().location

@description('Used to generate the resource name.')
param env string

@description('used as a part of the full resource name, to comply with TR naming standards')
param locationShorthand string

@description('The name of the app, to be reused everywhere')
param appName string = 'apimgmt'

@description('NSG name')
param apiMgmtNSGName string

@description('NSG security rules array')
param apiMgmtNSGSecurityRules array = [
  {
    name: 'Management_endpoint_for_Azure_portal_and_Powershell'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3443'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 1001
      direction: 'Inbound'
    }
  }
  {
    name: 'Azure_Infrastructure_Load_Balancer'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6390'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 1002
      direction: 'Inbound'
    }
  }
  {
    name: 'Dependency_on_Azure_Storage'
    properties: {
      description: 'APIM service dependency on Azure blob and Azure table storage'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 103
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_on_Azure_SQL'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '1433'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Sql'
      access: 'Allow'
      priority: 1004
      direction: 'Outbound'
    }
  }
  {
    name: 'Access_KeyVault'
    properties: {
      description: 'Allow API Management service control plane access to Azure Key Vault to refresh secrets'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureKeyVault'
      access: 'Allow'
      priority: 1005
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
      ]
    }
  }
  {
    name: 'Publish_DiagnosticLogs_And_Metrics'
    properties: {
      description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 1006
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
        '12000'
        '1886'
      ]
    }
  }
]

param vnetName string
param vnetAppSvcSubnetName string
param vnetAppSvcSubnetId string
// Private DNS
param vnetAppSvcId string
//param vnetCoreId string

@description('This value should not be change')
param privateDnsZoneName string = 'azure-api.net'
param organizationName string = 'TR'
param tags object = {
  Owner: 'tony@airwavetech.io'
  'Created By': 'tony@airwavetech.io'
  'Application Name': 'API Management Service'
  Environment: env
  Description: 'API Management service to control backend API calls'
  'Business Unit': 'Cloud Ops'
  Stakeholder: 'tony@airwavetech.io'
  'Tech Team': 'Cloud Ops'
  'Created Using': 'BICEP'
}

/// Resources

module privateDNS '../../../modules/private_dns_w_vnet_link.bicep' = {
  name: privateDnsZoneName
  params: {
    privateDnsZoneName: privateDnsZoneName
    tags: tags
    vnetAppSvcId: vnetAppSvcId
    // vnetCoreId: vnetCoreId
  }
}

module apiManagementService '../../../modules/api_management_internal.bicep' = {
  name: 'apiManagement'
  params: {
    appName: appName
    adminEmail: 'tony@airwavetech.io'
    capacity: 1
    customProperties: {}
    env: env
    location: location
    locationShorthand: locationShorthand
    organizationName: organizationName
    subnetApiMgmtID: vnetAppSvcSubnetId
    tags: tags
    tier: 'developer'
    zones: []

    virtualNetworkType: 'Internal'
    apiMgmtNSGName: apiMgmtNSGName
    apiMgmtNSGSecurityRules: apiMgmtNSGSecurityRules
    vnetSubnetName: vnetAppSvcSubnetName
    vnetName: vnetName
  }
}

module dnsRecords '../../../modules/private_dns_records.bicep' = {
  name: 'dnsRecords'
  params: {
    privateDnsZoneName: privateDnsZoneName
    dnsRecords: [
      {
        name: 'apim-apimgmt-${env}-${locationShorthand}.developer'
        ipv4Address: apiManagementService.outputs.ApiMgmtSvcPrivateIp
      }
      {
        name: 'apim-apimgmt-${env}-${locationShorthand}'
        ipv4Address: apiManagementService.outputs.ApiMgmtSvcPrivateIp
      }
      {
        name: 'apim-apimgmt-${env}-${locationShorthand}.management'
        ipv4Address: apiManagementService.outputs.ApiMgmtSvcPrivateIp
      }
      {
        name: 'apim-apimgmt-${env}-${locationShorthand}.configuration'
        ipv4Address: apiManagementService.outputs.ApiMgmtSvcPrivateIp
      }
      {
        name: 'apim-apimgmt-${env}-${locationShorthand}.scm'
        ipv4Address: apiManagementService.outputs.ApiMgmtSvcPrivateIp
      }
    ]
  }
}
