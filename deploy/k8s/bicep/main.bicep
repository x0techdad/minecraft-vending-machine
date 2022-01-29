// This Bicep template creates the required resource group and initaties deployment of resources.
//
//Project README: https://github.com/cool-tech-dad/minecraft-vending-machine 
//If you have questions or need help, reach out via Discord: https://discord.gg/aCnzN2QsQE
//If you want to contribute code, please see: https://github.com/cool-tech-dad/minecraft-vending-machine#contribute 

/*
Resource domains
1. Resource group
2. Resources
*/


//**deployment parameters**
param resource_name_prefix string = 'cooldadmvm'
param location string = deployment().location

/*.______       _______     _______.  ______    __    __  .______        ______  _______      _______ .______        ______    __    __  .______   
|   _  \     |   ____|   /       | /  __  \  |  |  |  | |   _  \      /      ||   ____|    /  _____||   _  \      /  __  \  |  |  |  | |   _  \  
|  |_)  |    |  |__     |   (----`|  |  |  | |  |  |  | |  |_)  |    |  ,----'|  |__      |  |  __  |  |_)  |    |  |  |  | |  |  |  | |  |_)  | 
|      /     |   __|     \   \    |  |  |  | |  |  |  | |      /     |  |     |   __|     |  | |_ | |      /     |  |  |  | |  |  |  | |   ___/  
|  |\  \----.|  |____.----)   |   |  `--'  | |  `--'  | |  |\  \----.|  `----.|  |____    |  |__| | |  |\  \----.|  `--'  | |  `--'  | |  |      
| _| `._____||_______|_______/     \______/   \______/  | _| `._____| \______||_______|    \______| | _| `._____| \______/   \______/  | _| */      
targetScope = 'subscription'
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-cooldad-mvm-aks'
  location: location
}                                                                                                                                                

/*.______       _______     _______.  ______    __    __  .______        ______  _______     _______   _______ .______    __        ______   ____    ____ .___  ___.  _______ .__   __. .___________.
|   _  \     |   ____|   /       | /  __  \  |  |  |  | |   _  \      /      ||   ____|   |       \ |   ____||   _  \  |  |      /  __  \  \   \  /   / |   \/   | |   ____||  \ |  | |           |
|  |_)  |    |  |__     |   (----`|  |  |  | |  |  |  | |  |_)  |    |  ,----'|  |__      |  .--.  ||  |__   |  |_)  | |  |     |  |  |  |  \   \/   /  |  \  /  | |  |__   |   \|  | `---|  |----`
|      /     |   __|     \   \    |  |  |  | |  |  |  | |      /     |  |     |   __|     |  |  |  ||   __|  |   ___/  |  |     |  |  |  |   \_    _/   |  |\/|  | |   __|  |  . `  |     |  |     
|  |\  \----.|  |____.----)   |   |  `--'  | |  `--'  | |  |\  \----.|  `----.|  |____    |  '--'  ||  |____ |  |      |  `----.|  `--'  |     |  |     |  |  |  | |  |____ |  |\   |     |  |     
| _| `._____||_______|_______/     \______/   \______/  | _| `._____| \______||_______|   |_______/ |_______|| _|      |_______| \______/      |__|     |__|  |__| |_______||__| \__|     |__| */     

module aksCluster 'aks.bicep' = {
  name: 'aksCluster'
  scope: resourceGroup
  params: {
    location: location
    resource_name_prefix: resource_name_prefix
    kubernetes_version: '1.20.9'
  }
}

//Genereate useful output
output std_out string = aksCluster.outputs.std_out

//ACSCII Art link : https://textkool.com/en/ascii-art-generator?hl=default&vl=default&font=Star%20Wars&text=changeme
