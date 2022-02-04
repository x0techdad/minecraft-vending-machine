# Minecraft container on ACI (CaaS)
<p align="center">
  <img src="../../images/mvm_logo.gif" width="400"></br>
  <a href="../../README.md">Home</a> |
  <a href="#prereqs">Prereqs</a> |
  <a href="#bicep">Bicep</a> |
  <a href="#terraform">Terraform</a> |
  <a href="#service">Service</a>
</p>

# Prereqs
1. Verify Azure CLI context before every deployment: `az account show`

# Deploy
Follow the deployment steps of your preffered IaC tool:
## Bicep 
  1. In your console, navigate to: `.\deploy\caas\bicep\`
  2. Open file: `.\aci.bicep`
  3. Modify Minecraft [server](https://minecraft.fandom.com/wiki/Server.properties) environmental settings if required, save and close file:
      * Minecraft server version, specify "latest" or full version number: `value: '1.18.2.03'`
        ```
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
        ```
  4. If you brought your own image, replace the URI in file `.\main.bicep `, save and close file.
  5. Validate deployment:

      `az deployment sub create --name deploy-cooldad-mvm-aci --template-file .\main.bicep --location eastus --what-if` 
  6. Apply deployment:
          
      `az deployment sub create --name deploy-cooldad-mvm-aks --template-file .\main.bicep --location eastus`
  5. Retrieve deployment outputs, take note of the ACI name and container IP address or save in CLI variable for future use: 
    
      `az deployment sub show -n deploy-cooldad-mvm-aci --query properties.outputs.aci_name.value`\
      `az deployment sub show -n deploy-cooldad-mvm-aci --query properties.outputs.container_ip.value`

Move onto the <a href="#service">service</a> section to complete deployment. 

## Terraform
  1. In your console, navigate to: `.\deploy\caas\terraform\`
  2. Open file: `.\main.tf`
  3. Modify Minecraft [server](https://minecraft.fandom.com/wiki/Server.properties) environmental settings if required, save and close file:
      * Minecraft server version, specify "latest" or full version number: `"bds_version" = "1.18.2.03"`
      * Environmental settings:
          ```
          environment_variables = {
            "debug" = "TRUE",
            "bds_version" = "1.18.2.03",
            "eula" = "TRUE",
            "level_name" = "Bedrock level",
            "gamemode" = "creative",
            "difficulty" = "normal",
            "allow_cheats" = "false",
            "max_players" = "1000",
            "server_authoritative_movement" = "server-auth-with-rewind"
          }
          ```
  4.If you brought your own image, replace the URI in file `.\variables.tf `, save and close file.
  5. Initialize Terraform and required backend (local state): 
  
      `terraform init`
  6. Validate deployment: 
  
      `terraform validate`
  7. Apply deployment, supply preferred region (eg. eastus), accept changes: 
  
      `terraform apply`
  8. Take note of the container name and IP address in the deployment output, or save in CLI variables for future use:
      
      `aci_name = "acicooldadmvmxxxx"`\
      `container_ip = "x.x.x.x"`

Move onto the next section to complete deployment. 

## Service
  1. Validate infrastructure deployment and server service:
      * Start the log stream:

        `az container attach --resource-group rg-cooldad-mvm-aci --name <container_name>`
      
      * Look for the following in the log output:
        * Correct server version:
        * Correct server settings
        * Server is up and listening: `IPv4 supported, port: 19132`
        <p align="center">
          <img src="../../images/mvm_deploy_server_success.png" width=500>
        </p>

🎉 Congrats, you have successfully deployed a Minecraft BDS server , in a container, on the public cloud, its time to <a href="../deploy.md#connect">connect & play:video_game: !</a> 

  <p align="center">
    <img src="https://media3.giphy.com/media/l49K1yUmz5LjIu0GA/giphy.gif" width=300>
  </p>


## Deployment t-shooting
* Use [platform activity](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log#view-the-activity-log) logs to investigatge deployment errors.
* Use [container](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-get-logs) logs to investigate runtime errors. 