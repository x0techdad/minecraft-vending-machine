// This Bicep template is used to specify the desired configuration of the AKS service.
// Please use the _main.params.json file to make your deployment unique, there should be 
// no need to modify this file to deploy the supported project scenarios. 
//
//Project README: https://github.com/cool-tech-dad/minecraft-vending-machine 
//If you have questions or need help, reach out via Discord: https://discord.gg/aCnzN2QsQE
//If you want to contribute code, please see: https://github.com/cool-tech-dad/minecraft-vending-machine#contribute 

/*
Resource domains
1. Networking
2. DNS Zones
3. Key Vault
4. Container Registry
5. AKS
6. Monitoring
*/

//**deployment parameters**
//global settings:
@description('Used to name all resources')
@minLength(3)
@maxLength(20)
param resource_name_prefix string
param location string = resourceGroup().location

//security settings:
// for AAD Integrated Cluster using 'enable_azure_rbac', add Cluster admin to the current user!
param admin_principle_id string = ''

//governance settings:
param dev bool
param kubernetes_version string = '1.20.9'
param aks_paid_sku_for_sla bool = false

//iam settings:
param enable_aad bool = true
param aad_tenant_id string = ''
param enable_azure_rbac bool = true

//compute / general agent pool settings:
@description('Pool tier sizing presets')
@allowed([
  'cost-optimized'
  'standard'
  'premium'
])


/*.__   __.  _______ .___________.____    __    ____  ______   .______       __  ___  __  .__   __.   _______ 
|  \ |  | |   ____||           |\   \  /  \  /   / /  __  \  |   _  \     |  |/  / |  | |  \ |  |  /  _____|
|   \|  | |  |__   `---|  |----` \   \/    \/   / |  |  |  | |  |_)  |    |  '  /  |  | |   \|  | |  |  __  
|  . `  | |   __|      |  |       \            /  |  |  |  | |      /     |    <   |  | |  . `  | |  | |_ | 
|  |\   | |  |____     |  |        \    /\    /   |  `--'  | |  |\  \----.|  .  \  |  | |  |\   | |  |__| | 
|__| \__| |_______|    |__|         \__/  \__/     \______/  | _| `._____||__|\__\ |__| |__| \__|  \______| */
//No enhanced networking required, defaults applied. 



/*______  .__   __.      _______.    ________    ______   .__   __.  _______      _______.
|       \ |  \ |  |     /       |   |       /   /  __  \  |  \ |  | |   ____|    /       |
|  .--.  ||   \|  |    |   (----`   `---/  /   |  |  |  | |   \|  | |  |__      |   (----`
|  |  |  ||  . `  |     \   \          /  /    |  |  |  | |  . `  | |   __|      \   \    
|  '--'  ||  |\   | .----)   |        /  /----.|  `--'  | |  |\   | |  |____ .----)   |   
|_______/ |__| \__| |_______/        /________| \______/  |__| \__| |_______||_______/    */
//Default Azure DNS provider deployed with AKS Cluster



/*__  __  _______ ____    ____    ____    ____  ___      __    __   __      .___________.
|  |/  / |   ____|\   \  /   /    \   \  /   / /   \    |  |  |  | |  |     |           |
|  '  /  |  |__    \   \/   /      \   \/   / /  ^  \   |  |  |  | |  |     `---|  |----`
|    <   |   __|    \_    _/        \      / /  /_\  \  |  |  |  | |  |         |  |     
|  .  \  |  |____     |  |           \    / /  _____  \ |  `--'  | |  `----.    |  |     
|__|\__\ |_______|    |__|            \__/ /__/     \__\ \______/  |_______|    |__|     */
//No KMS required



/*   ___           ______     .______          
    /   \         /      |    |   _  \         
   /  ^  \       |  ,----'    |  |_)  |        
  /  /_\  \      |  |         |      /         
 /  _____  \   __|  `----. __ |  |\  \----. __ 
/__/     \__\ (__)\______|(__)| _| `._____|(__)*/

//No Azure Container registry required, hosting image on Docker Hub



/*_  ___  __    __  .______    _______ .______      .__   __.  _______ .___________. _______      _______.
|  |/  / |  |  |  | |   _  \  |   ____||   _  \     |  \ |  | |   ____||           ||   ____|    /       |
|  '  /  |  |  |  | |  |_)  | |  |__   |  |_)  |    |   \|  | |  |__   `---|  |----`|  |__      |   (----`
|    <   |  |  |  | |   _  <  |   __|  |      /     |  . `  | |   __|      |  |     |   __|      \   \    
|  .  \  |  `--'  | |  |_)  | |  |____ |  |\  \----.|  |\   | |  |____     |  |     |  |____ .----)   |   
|__|\__\  \______/  |______/  |_______|| _| `._____||__| \__| |_______|    |__|     |_______||_______/ */

//agent general settings:
param pool_tier string
param auto_scale bool
param os_disk_type string = 'Ephemeral'
param os_disk_size_gb int = 0
param pool_node_max int = 3
param availability_zones array = []

//agent pool 01 settings:
param user_pool01_name string = 'npmcbds001'
param user_pool01_labels object = {
  app: 'mc-bds-001'
}

//network settings:
param network_plugin string = 'azure'
param network_policy string = ''
param dns_prefix string = '${resource_name_prefix}-dns'
param pod_cidr string = '10.244.0.0/16'
param service_cidr string = '10.0.0.0/16'
param dns_service_ip string = '10.0.0.10'
param docker_bridge_cidr string = '172.17.0.1/16'


//deployment variables:
var aks_sku = aks_paid_sku_for_sla ? 'Paid' : 'Free'
var pool_presets_base = {
  osType: 'Linux'
  type: 'VirtualMachineScaleSets'
  enableAutoScaling: auto_scale
  maxCount: auto_scale ? pool_node_max: json('null')
  availabilityZones: !empty(availability_zones) && !dev ? availability_zones : null
  upgradeSettings: {
    maxSurge: '33%'
  }
}
var system_pool_presets = {
  name: 'npsystem'
  mode: 'System'
  count: 1
  maxPods: 30
  nodeTaints: [
    dev ? '' : 'CriticalAddonsOnly=true:NoSchedule'
  ]
}
var system_pool_sizing = {
  'cost-optimized' : {
    vmSize: 'Standard_B4ms'
    minCount: auto_scale ? 1 : json('null')
  }
  'standard' : {
    vmSize: 'Standard_D2_v5'
    minCount: auto_scale ? 1 : json('null')
  }
  'premium' : {
    vmSize: 'Standard_D4s_v5'
    minCount: auto_scale ? 2 : json('null')
  }
}
var system_pool_profile = union(pool_presets_base, system_pool_presets, system_pool_sizing[pool_tier])
var user_pool_presets = {
  mode: 'User'
  count: 1
  os_disk_type: os_disk_type
  os_disk_size_gb: os_disk_size_gb
}
var user_pool_sizing = {
  'cost-optimized' : {
    vmSize: 'Standard_B4ms'
    maxPods: 10
    minCount: auto_scale ? 1 : json('null')
  }
  'standard' : {
    vmSize: 'Standard_B4ms_v3'
    maxPods: 30
    minCount: auto_scale ? 1 : json('null')
  }
  'premium' : {
    vmSize: 'Standard_D4s_v5'
    maxPods: 30
    minCount: auto_scale ? 2 : json('null')
  }
}
var user_pool_01_name = dev ? {} : { 
  name: user_pool01_name
}
var user_pool_01_labels = dev ? {} : { 
  nodeLabels: user_pool01_labels
}
var user_pool_profile01= union( user_pool_01_name, user_pool_01_labels, pool_presets_base, user_pool_presets, user_pool_sizing[pool_tier])
var pool_profiles = dev ? array(system_pool_profile) : concat(array(system_pool_profile), array(user_pool_profile01))

var aks_properties_base = {
  kubernetesVersion: kubernetes_version
  enableRBAC: true
  dnsPrefix: dns_prefix
  aadProfile: enable_aad ? {
    managed: true
    enableAzureRbac: enable_azure_rbac
    tenantID: aad_tenant_id
  } : null
  agentPoolProfiles: pool_profiles
  networkProfile: {
    loadBalancerSku: 'standard'
    networkPlugin: network_plugin
    networkPolicy: network_policy
    podCidr: pod_cidr
    serviceCidr: service_cidr
    dnsServiceIP: dns_service_ip
    dockerBridgeCidr: docker_bridge_cidr
  }
}

//Resources:
resource aks 'Microsoft.ContainerService/managedClusters@2021-07-01' = {
  name: 'aks${resource_name_prefix}'
  location: location
  properties: aks_properties_base
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: aks_sku
  }
}
output aks_name string = aks.name

//Assigning specified user principal to CLuster Admin role if Azure RBAC is enabled too. 
var build_in_aks_rbac_cluster_admin = resourceId('Microsoft.Authorization/roleDefinitions', 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b')
resource aks_admin_role_assignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = if (enable_azure_rbac && !empty(admin_principle_id)) {
  scope: aks // Use when specifying a scope that is different than the deployment scope
  name: '${guid(aks.id, 'aksadmin', build_in_aks_rbac_cluster_admin)}'
  properties: {
    roleDefinitionId: build_in_aks_rbac_cluster_admin
    principalType: 'User'
    principalId: admin_principle_id
  }
}



/*__  ___.   ______   .__   __.  __  .___________.  ______   .______       __  .__   __.   _______ 
|   \/   |  /  __  \  |  \ |  | |  | |           | /  __  \  |   _  \     |  | |  \ |  |  /  _____|
|  \  /  | |  |  |  | |   \|  | |  | `---|  |----`|  |  |  | |  |_)  |    |  | |   \|  | |  |  __  
|  |\/|  | |  |  |  | |  . `  | |  |     |  |     |  |  |  | |      /     |  | |  . `  | |  | |_ | 
|  |  |  | |  `--'  | |  |\   | |  |     |  |     |  `--'  | |  |\  \----.|  | |  |\   | |  |__| | 
|__|  |__|  \______/  |__| \__| |__|     |__|      \______/  | _| `._____||__| |__| \__|  \______| */
//No enhanced monitoring required

//ACSCII Art link : https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Star%20Wars&text=changeme
