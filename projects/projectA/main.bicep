targetScope = 'subscription'
param location string = deployment().location
@description('used as a part of the full resource name, to comply with TR naming standards')
param env string = 'test'
@description('used as a part of the full resource name, to comply with TR naming standards')
param locationShorthand string = 'wus'
@description('The name of the app, to be reused everywhere')
param appName string = 'cloudops'

param tags object = {
  Owner: 'tony@airwavetech.io'
  'Created By': 'tony@airwavetech.io'
  'Application Name': appName
  Environment: env
  Description: 'Description field'
  'Business Unit': 'Cloud Ops'
  Stakeholder: 'tony@airwavetech.io'
  'Tech Team': 'Cloud Ops'
  'Created Using': 'BICEP'
}

module resourceGroup '../../modules/resource_group.bicep' = {
  name: 'resourceGroup'
  params: {
    location: location
    tags: tags
    env: env
    locationShorthand: locationShorthand
    appName: appName
  }
}
