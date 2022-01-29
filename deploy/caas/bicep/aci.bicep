
/*
Resource domains
1. Azure Files
2. ACI
*/

//**global parameters**
@description('Used to name all resources')
@minLength(3)
@maxLength(20)
param resource_name_prefix string
param location string

//**global variables**
var random_string = '${take(uniqueString(resourceGroup().id), 4)}'
var resource_name_prefix_raw = '${resource_name_prefix}${random_string}'
var resource_name_prefix_safe = '${toLower(replace(resource_name_prefix_raw, '-', ''))}'

/*   ___      ________   __    __  .______       _______     _______  __   __       _______     _______.
    /   \    |       /  |  |  |  | |   _  \     |   ____|   |   ____||  | |  |     |   ____|   /       |
   /  ^  \   `---/  /   |  |  |  | |  |_)  |    |  |__      |  |__   |  | |  |     |  |__     |   (----`
  /  /_\  \     /  /    |  |  |  | |      /     |   __|     |   __|  |  | |  |     |   __|     \   \    
 /  _____  \   /  /----.|  `--'  | |  |\  \----.|  |____    |  |     |  | |  `----.|  |____.----)   |   
/__/     \__\ /________| \______/  | _| `._____||_______|   |__|     |__| |_______||_______|_______/
*/

//**azure files parameters**
//governance:
param smb_share_name string = 'pvmcbds001'
param sta_sku string = 'Premium_LRS'
param share_tier string = 'Premium'

//security:
param min_tls_version string = 'TLS1_2'

//**variables**
var sta_name = 'mvmsta${resource_name_prefix_safe}'
var sta_properties = {
  encryption: {
    requireInfrastructureEncryption: true
    keySource: 'Microsoft.Storage'
    services: {
      file: {
        enabled: true
        keyType: 'Account'
      }
    }
  }
  minimumTlsVersion: min_tls_version
  supportsHttpsTrafficOnly: true
}

//**deploy resources**
//file storage account
resource sta 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: sta_name
  location: location
  sku: {
    name: sta_sku
  }
  kind: 'FileStorage'
  properties: sta_properties
}

//file service
resource file 'Microsoft.Storage/storageAccounts/fileServices@2021-06-01' = {
  name: 'default'
  parent: sta
  properties: {
    protocolSettings: {
      smb: {
        multichannel: {
          enabled: true
        }
      }
    }
  }
}

//share
resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-06-01' = {
  name: smb_share_name
  parent: file
  properties: {
    accessTier: share_tier
  }
}


/*   ___       ______  __       ___  ______     ___           ___           _______.___  
    /   \     /      ||  |     /  / /      |   /   \         /   \         /       |\  \ 
   /  ^  \   |  ,----'|  |    |  | |  ,----'  /  ^  \       /  ^  \       |   (----` |  |
  /  /_\  \  |  |     |  |    |  | |  |      /  /_\  \     /  /_\  \       \   \     |  |
 /  _____  \ |  `----.|  |    |  | |  `----./  _____  \   /  _____  \  .----)   |    |  |
/__/     \__\ \______||__|    |  |  \______/__/     \__\ /__/     \__\ |_______/     |  |
                               \__\                                                 /__/ 
*/

//**aci parameters**
//governance:
param docker_image_uri string
param os_type string = 'Linux'
param volume_name string = 'pv001'

//**variables**
var container_dns = 'aci${resource_name_prefix_safe}dns'
var aci_properties = {
  osType: os_type
  sku: 'Standard'
  ipAddress: {
    type: 'Public'
    dnsNameLabel: container_dns
    ports: [
      {
        port: 19132
        protocol: 'UDP'
      }
    ] 
  }
  volumes: [
    {
      name: volume_name
      azureFile: {
        shareName: share.name
        storageAccountKey: sta.listKeys().keys[0].value
        storageAccountName: sta.name
      }

    }
  ]
  containers: [
    {
      name: 'mcbds001'
      properties: {
        image: docker_image_uri
        resources: {
          requests: {
            cpu: 1
            memoryInGB: 2
          }
        }
        ports: [
          {
            port: 19132
            protocol: 'UDP'
          }
        ]
        volumeMounts: [
          {
            name: volume_name
            mountPath: '/data'
          }
        ]
        environmentVariables: [
          {
            name: 'debug'
            value: 'true'
          }
          {
            name: 'bds_version'
            value: '1.18.2.03'
          }
          {
            name: 'eula'
            value: 'true'
          }
          {
            name: 'level_name'
            value: 'Bedrock level'
          }
          {
            name: 'gamemode'
            value: 'creative'
          }
          {
            name: 'difficulty'
            value: 'normal'
          }
          {
            name: 'allow_cheats'
            value: 'false'
          }
          {
            name: 'max_players'
            value: '1000'
          }
          {
            name: 'server_authoritative_movement'
            value: 'server-auth-with-rewind'
          }
        ]
      }
    }
  ]
}

//**deploy resources**
//aci
resource aci 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: 'aci${resource_name_prefix_safe}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: aci_properties
}


//Genereate useful output
output aci_name string = aci.name
output container_ip string = aci.properties.ipAddress.ip

//ACSCII Art link : https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Star%20Wars&text=changeme
