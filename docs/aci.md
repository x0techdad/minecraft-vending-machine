# Minecraft Vending Machine
<p align="center">
  <img src="../images/mvm_logo.gif" width="400"></br>
  <a href="../readme.md">Home</a> |
  <a href="#prereqs">Prereqs</a> |
  <a href="#bicep">Bicep</a> |
  <a href="#terraform">Terraform</a> |
  <a href="#service">Service</a>
</p>

# Minecraft BDS container on ACI (CaaS)
# Prereqs
None
# Deploy
Follow the deployment steps for your preffered IaC tool: 
### Bicep
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

### Terraform
  1. In your console, navigate to: `.\minecraft-vending-machine\deploy-aci\terraform`
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
  3. Initialize Terraform and required backend (local): 
  
      `terraform init`
  4. Validate deployment:

      `terraform validate`
  5. Apply deployment, supply preferred region (eg. eastus), accept changes:

      `terraform apply`
  6. Take note of the container name and IP address in the deployment output, or save in CLI variables for future use:
      
      `container_name = "acicooldadmvmxxxx"`\
      `container_ip_address = "x.x.x.x"`

### Service
  1. Validate Minecraft server:
      * Start the log stream:

        `az container attach --resource-group rg-cooldad-mvm-aci --name <container_name>`
      
      * Look for the following in the `Info` log output:
        * Correct server settings
        * Server is up and listening: `IPv4 supported, port: 19132`
        <p align="center">
          <img src="../images/mvm_deploy_server_success.png" width=500>
        </p>

🎉 Congrats, you have successfully deployed a Minecraft BDS server , in a container, on the public cloud, its time to <a href="../readme.md#connect">connect & play:video_game: !</a> 

  <p align="center">
    <img src="https://media3.giphy.com/media/l49K1yUmz5LjIu0GA/giphy.gif" width=300>
  </p>
      
### Deployment t-shooting
* Use [platform activity](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log#view-the-activity-log) logs to investigatge deployment errors.
### Additional deployment scenarios
  * Using a custom Docker image will be added in the next version.  
<!---* Using a custom Docker image:
  * Retrieve the URI of your custom image, should look something like this if hosted on Docker Hub: `docker.io/<namespace>/<image name>:<tag>`
  * Specify your ACR's name and the image to use/pull on line 25
  * If you are using the CoolTechDad image, only plug in your ACR's name\
  `image: <acr_name>.azurecr.io/cooltechdad/minecraft-bds:0.5`
  * If you are creating your own image, plug in your ACR's name and image details\
  `image: <acr_name>.azurecr.io/<namespace/image name:image tag>`
  6. Tag and push/upload image to Docker Hub

      `docker tag <image name>:<tag> <namespace>/<image name>:<tag>`

      `docker push <namespace>/<image name>:<tag>`
    
      * Real-world example\
        `docker tag minecraft-bds:0.5 cooltechdad/minecraft-bds:0.5`

        `docker push cooltechdad/minecraft-bds:0.5`


  * Add additional node pool, deploy multiple Minecraft servers on a single cluster. Included in the next version.--->