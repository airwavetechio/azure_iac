param privateDnsZoneName string

param dnsRecords array = [
  // Default example to show structure
  // {
  //   name: 'record1'
  //   ipv4Address: '192.0.2.1'
  // },
  // {
  //   name: 'record2'
  //   ipv4Address: '192.0.2.2'
  // }
]

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: privateDnsZoneName
}

resource privateDnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = [
  for record in dnsRecords: {
    parent: privateDnsZone
    name: record.name
    properties: {
      ttl: 3600
      aRecords: [
        {
          ipv4Address: record.ipv4Address
        }
      ]
    }
  }
]
