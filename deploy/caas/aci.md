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
Code for this deployment pattern will be available soon.  
<!-- 1. In your console, navigate to: `.\minecraft-vending-machine\deploy-aci\bicep`
  2. Customize the Minecraft server runtime properties: 
      * Open file `.\main.tf` with your preffered text editor.
      * Modify [server](https://minecraft.fandom.com/wiki/Server.properties) settings to change the game experience:
        ```
        environment_variables = {
          "debug" = "true",
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
      * Save your changes and close the file

  2. Validate deployment:

      `az deployment sub create --name deploy-cooldad-mvm-aks --template-file .\main.bicep --location eastus --what-if`
  3. Apply deployment:
          
      `az deployment sub create --name deploy-cooldad-mvm-aks --template-file .\main.bicep --location eastus`
      
  4. Retrieve deployment outputs, take note of cluster's name or save in CLI variable for future use: 
    
      `az deployment sub show -n deploy-cooldad-mvm-aks --query properties.outputs.std_out.value ` 
-->

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
  4. If your using a custom container image, replace the URI in file `.\variables.tf `, save and close file.
  5. Initialize Terraform and required backend (local state): 
  
      `terraform init`
  6. Validate deployment: 
  
      `terraform validate`
  7. Apply deployment, supply preferred region (eg. eastus), accept changes: 
  
      `terraform apply`
  8. Take note of the container name and IP address in the deployment output, or save in CLI variables for future use:
      
      `container_name = "acicooldadmvmxxxx"`\
      `container_ip_address = "x.x.x.x"`

## Service
  1. Validate Minecraft server:
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