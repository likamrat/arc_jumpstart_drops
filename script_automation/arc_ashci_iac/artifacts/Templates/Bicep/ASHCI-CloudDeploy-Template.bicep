@description('First must pass Validate prior running Deploy')
@allowed([
  'Validate'
  'Deploy'
])
param deploymentMode string = 'Validate'

@description('The KeyVault name used to store the secrets.')
param keyVaultName string
param softDeleteRetentionDays int = 30

@description('The name of the storage account used for KV audit logs')
param diagnosticStorageAccountName string

@allowed([
  'new'
  'existing'
])
param diagaccount_newOrExisting string = 'new'

@description('Specifies the number of days that logs are gonna be kept. If you do not want to apply any retention policy and retain data forever, set value to 0.')
@minValue(0)
@maxValue(365)
param logsRetentionInDays int = 30

@description('Storage Account type')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('The fqdn of your KeyVault')
param secretsLocation string = ''

@description('The existing storage account name used for the cluster witness')
param ClusterWitnessStorageAccountName string = ''

@minLength(3)
@maxLength(24)
param clusterName string
param location string = resourceGroup().location
param tenantId string = subscription().tenantId

@description('The name can not be changed')
@allowed([
  'LocalAdminCredential'
])
param localAdminSecretName string = 'LocalAdminCredential'

@secure()
param localAdminSecretValue string

@description('The name can not be changed')
@allowed([
  'AzureStackLCMUserCredential'
])
param domainAdminSecretName string = 'AzureStackLCMUserCredential'

@secure()
param domainAdminSecretValue string

@description('The name can not be changed')
@allowed([
  'DefaultARBApplication'
])
param arbDeploymentSpnName string = 'DefaultARBApplication'

@secure()
param arbDeploymentSpnValue string

@description('The name can not be changed')
@allowed([
  'WitnessStorageKey'
])
param storageWitnessName string = 'WitnessStorageKey'

@secure()
param storageWitnessValue string

@description('The api version for deploying a hci cluster')
param apiVersion string = ''

@description('The arc for server node Ids of the hci cluster')
param arcNodeResourceIds array = []

@description('The domain name of the Active Directory Domain Services')
param domainFqdn string = ''

@description('The ADFS name prefix')
param namingPrefix string = ''

@description('The ADDS OU path')
param adouPath string = ''

@description('The security level data for deploying a hci cluster')
@allowed([
  'Recommended'
  'Customized'
])
param securityLevel string = 'Recommended'

@description('The security setting driftControlEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param driftControlEnforced bool = true

@description('The security setting credentialGuardEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param credentialGuardEnforced bool = true

@description('The security setting smbSigningEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param smbSigningEnforced bool = true

@description('The security setting smbClusterEncryption data for deploying a hci cluster')
@allowed([
  true
  false
])
param smbClusterEncryption bool = false

@description('The security setting bitlockerBootVolume data for deploying a hci cluster')
@allowed([
  true
  false
])
param bitlockerBootVolume bool = true

@description('The security setting bitlockerDataVolumes data for deploying a hci cluster')
@allowed([
  true
  false
])
param bitlockerDataVolumes bool = true

@description('The security setting wdacEnforced data for deploying a hci cluster')
@allowed([
  true
  false
])
param wdacEnforced bool = true

@description('The metrics data for deploying a hci cluster')
@allowed([
  true
  false
])
param streamingDataClient bool = true

@description('The location data for deploying a hci cluster')
@allowed([
  true
  false
])
param euLocation bool = false

@description('The diagnostic data for deploying a hci cluster')
@allowed([
  true
  false
])
param episodicDataUpload bool = true

@description('The storage volume configuration mode')
@allowed([
  'Express'
  'InfraOnly'
  'KeepStorage'
])
param configurationMode string = 'Express'

@description('The subnet mask for deploying a hci cluster')
param subnetMask string = ''

@description('The default gateway for deploying a hci cluster')
param defaultGateway string = ''

@description('The starting ip address for deploying a hci cluster')
param startingIPAddress string = ''

@description('The ending ip address for deploying a hci cluster')
param endingIPAddress string = ''

@description('The dns servers for deploying a hci cluster')
param dnsServers array = [
  ''
]

@description('The physical nodes settings for deploying a hci cluster')
param physicalNodesSettings array = [
  {
    name: 'node1'
    ipv4Address: '100.69.32.64'
  }
  {
    name: 'node2'
    ipv4Address: '100.69.32.65'
  }
]

@description('The networking type for deploying a hci cluster')
@allowed([
  'switchedMultiServerDeployment'
  'switchlessMultiServerDeployment'
  'singleServerDeployment'
])
param networkingType string = ''

@description('The intent list for deploying a hci cluster')
param intentList array = []

@description('The storage network list for deploying a hci cluster')
param storageNetworkList array = []

@description('The storage connectivity switchless value for deploying a hci cluster')
param storageConnectivitySwitchless bool = false

@description('The custom location for deploying a hci cluster')
param customLocation string = ''

resource Microsoft_Storage_storageAccounts_diagnosticStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' =
  if (diagaccount_newOrExisting == 'new') {
    name: diagnosticStorageAccountName
    location: location
    sku: {
      name: storageAccountType
      tier: 'Standard'
    }
    kind: 'StorageV2'
    properties: {
      supportsHttpsTrafficOnly: true
    }
  }

resource Microsoft_Storage_storageAccounts_diagnosticStorageAccount 'Microsoft.Storage/storageAccounts@2021-01-01' =
  if (diagaccount_newOrExisting == 'existing') {
    location: location
    kind: 'StorageV2'
    properties: {
      supportsHttpsTrafficOnly: true
    }
    sku: {
      name: storageAccountType
      tier: 'Standard'
    }
    name: diagnosticStorageAccountName
  }

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionDays
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    accessPolicies: []
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
  dependsOn: [
    Microsoft_Storage_storageAccounts_diagnosticStorageAccount
  ]
}

resource keyVaultName_Microsoft_Insights_service 'Microsoft.KeyVault/vaults/providers/diagnosticsettings@2016-09-01' = {
  name: '${keyVaultName}/Microsoft.Insights/service'
  location: resourceGroup().location
  properties: {
    storageAccountId: Microsoft_Storage_storageAccounts_diagnosticStorageAccount.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: logsRetentionInDays
        }
      }
    ]
  }
  dependsOn: [
    keyVault
  ]
}

resource cluster 'Microsoft.AzureStackHCI/clusters@2024-02-15-preview' =
  if (deploymentMode == 'Validate') {
    name: clusterName
    identity: {
      type: 'SystemAssigned'
    }
    location: location
    properties: {}
    dependsOn: [
      keyVault
    ]
  }

resource keyVaultName_domainAdminSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: '${domainAdminSecretName}'
  location: location
  scale: null
  properties: {
    contentType: 'Secret'
    value: domainAdminSecretValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_localAdminSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: '${localAdminSecretName}'
  location: location
  scale: null
  properties: {
    contentType: 'Secret'
    value: localAdminSecretValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_arbDeploymentSpn 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: '${arbDeploymentSpnName}'
  location: location
  scale: null
  properties: {
    contentType: 'Secret'
    value: arbDeploymentSpnValue
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultName_storageWitness 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  parent: keyVault
  name: '${storageWitnessName}'
  location: location
  scale: null
  properties: {
    contentType: 'Secret'
    value: storageWitnessValue
    attributes: {
      enabled: true
    }
  }
}

resource clusterName_default 'microsoft.azurestackhci/clusters/deploymentSettings@2024-02-15-preview' = {
  parent: cluster
  name: 'default'
  properties: {
    arcNodeResourceIds: arcNodeResourceIds
    deploymentMode: deploymentMode
    deploymentConfiguration: {
      version: '10.0.0.0'
      scaleUnits: [
        {
          deploymentData: {
            securitySettings: {
              hvciProtection: true
              drtmProtection: true
              driftControlEnforced: driftControlEnforced
              credentialGuardEnforced: credentialGuardEnforced
              smbSigningEnforced: smbSigningEnforced
              smbClusterEncryption: smbClusterEncryption
              sideChannelMitigationEnforced: true
              bitlockerBootVolume: bitlockerBootVolume
              bitlockerDataVolumes: bitlockerDataVolumes
              wdacEnforced: wdacEnforced
            }
            observability: {
              streamingDataClient: streamingDataClient
              euLocation: euLocation
              episodicDataUpload: episodicDataUpload
            }
            cluster: {
              name: clusterName
              witnessType: 'Cloud'
              witnessPath: ''
              cloudAccountName: ClusterWitnessStorageAccountName
              azureServiceEndpoint: 'core.windows.net'
            }
            storage: {
              configurationMode: configurationMode
            }
            namingPrefix: namingPrefix
            domainFqdn: domainFqdn
            infrastructureNetwork: [
              {
                subnetMask: subnetMask
                gateway: defaultGateway
                ipPools: [
                  {
                    startingAddress: startingIPAddress
                    endingAddress: endingIPAddress
                  }
                ]
                dnsServers: dnsServers
              }
            ]
            physicalNodes: physicalNodesSettings
            hostNetwork: {
              intents: intentList
              storageNetworks: storageNetworkList
              storageConnectivitySwitchless: storageConnectivitySwitchless
            }
            adouPath: adouPath
            secretsLocation: secretsLocation
            optionalServices: {
              customLocation: customLocation
            }
          }
        }
      ]
    }
  }
}
