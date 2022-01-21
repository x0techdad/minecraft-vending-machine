# Minecraft Vending Machine
<p align="center">
  <img src="../images/mvm_logo.gif" width="400"></br>
  <a href="../readme.md">Home</a> |
  <a href="#prereqs">Prereqs</a> |
  <a href="#bicep">Bicep</a> |
  <a href="#terraform">Terraform</a> |
  <a href="#service">Service</a>
</p>

# Minecraft BDS container on AKS (K8S)
# Prereqs
* Additional permissions are required to manage the K8S cluster once deployed. [Assign]((https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-steps)) the following Azure RBAC roles to your username at the subscription level:  
  * [AKS Cluster Admin](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-cluster-admin-role)
  * [AKS Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-contributor-role)
  * [AKS Service RBAC Cluster Admin](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#azure-kubernetes-service-rbac-cluster-admin)
* In your console, navigate to: `.\minecraft-vending-machine\deploy-aks`
* Customize the Minecraft server runtime properties: 
  * Open file `.\minecraft_bds.yml` with your preffered text editor.
  * Modify [server](https://minecraft.fandom.com/wiki/Server.properties) settings to change the game experience:

    ```
    - name: level_name #changing value results in player data loss
      value: "Bedrock level"            
    - name: gamemode
      value: "creative"
    - name: difficulty
      value: "normal"
    - name: allow_cheats
      value: "false"
    - name: max_players
      value: "1000"
    ```
  * Save your changes and close the file

# Deploy
Follow the deployment steps for your preffered IaC tool: 
### Bicep
  1. In your console, navigate to: `.\minecraft-vending-machine\deploy-aks\bicep`
  2. Validate deployment:

      `az deployment sub create --name deploy-cooldad-mvm-aks --template-file .\main.bicep --location eastus --what-if`
  3. Apply deployment:
          
      `az deployment sub create --name deploy-cooldad-mvm-aks --template-file .\main.bicep --location eastus`
      
  4. Retrieve deployment outputs, take note of cluster's name or save in CLI variable for future use: 
    
      `az deployment sub show -n deploy-cooldad-mvm-aks --query properties.outputs.std_out.value `

### Terraform
  1. In your console, navigate to: `.\minecraft-vending-machine\deplo-aks\terraform`
  2. Initialize Terraform and required backend (local): 
  
      `terraform init`
  3. Validate deployment:

      `terraform validate`
  4. Apply deployment, supply preferred region (eg. eastus), accept changes:

      `terraform apply`
  5. Take note of the cluster name in the deployment output or save in CLI variable for future use. 

### Service
1. Log into the cluster, use name retrieved in the previous step: 

      `az aks get-credentials --resource-group rg-cooldad-mvm-aks --name <aks_name>`
2. Configure Persistent Volume Claims (PVCs)

      `kubectl apply -f ..\azure_files_pvc.yaml`
3. Deploy Minecraft server:
    * Launch the container and configure the service

      `kubectl apply -f ..\minecraft_bds.yaml`
    * Start the log stream:

      `kubectl logs -f statefulSets/ss-mc-bds-001`
      
    * Look for the following in the `Info` log output:
      * Correct server settings
      * Server is up and listening: `IPv4 supported, port: 19132`
      <p align="center">
        <img src="../images/mvm_deploy_server_success.png" width=400>
      </p>

    * Get the details of the service's public ingress interface (Load balancer): `kubectl describe service lb-mc-bds`

      <p align="center">
        <img src="../images/mvm_k8s_service_lb.png"  width=400>
      </p>
      
      * Take note of the value listed for `LoadBalancer Ingress`, this is the public IP address you and guests will use to connect. 

🎉 Congrats, you have successfully deployed a Minecraft BDS server , in a container, on K8S, in the public cloud, its time to <a href="../readme.md#connect">connect & play:video_game: !</a> 

  <p align="center">
    <img src="https://media3.giphy.com/media/l49K1yUmz5LjIu0GA/giphy.gif"  width=300>
  </p>
      
### Deployment t-shooting
* Use [platform activity](https://docs.microsoft.com/en-us/azure/azure-monitor/essentials/activity-log#view-the-activity-log) logs to investigatge deployment errors.
* Use [kubelet](https://docs.microsoft.com/en-us/azure/aks/kubelet-logs) logs from AKS nodes to investigatge cluster configuration errors.
### Additional deployment scenarios
  * Using a custom Docker image will be added in the next version.  
<!---
* Using a custom Docker image:
  * Retrieve the URI of your custom image, should look something like this if hosted on Docker Hub: `docker.io/<namespace>/<image name>:<tag>`


  * Specify your ACR's name and the image to use/pull on line 25
  * If you are using the CoolTechDad image, only plug in your ACR's name\
  `image: <acr_name>.azurecr.io/cooltechdad/minecraft-bds:0.5`
  * If you are creating your own image, plug in your ACR's name and image details\
  `image: <acr_name>.azurecr.io/<namespace/image name:image tag>`

##### Custom Docker Image
  6. Tag and push/upload image to Docker Hub

      `docker tag <image name>:<tag> <namespace>/<image name>:<tag>`

      `docker push <namespace>/<image name>:<tag>`
    
      * Real-world example\
        `docker tag minecraft-bds:0.5 cooltechdad/minecraft-bds:0.5`

        `docker push cooltechdad/minecraft-bds:0.5`


  * Add additional node pool, deploy multiple Minecraft servers on a single cluster. Included in the next version.--->