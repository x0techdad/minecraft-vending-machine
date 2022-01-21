# Minecraft Vending Machine
<p align="center">
  <img src="../_img/mvm_logo.gif" width="400"></br>
  <a href="../readme.md">Home</a>
</p>

# Lessons learned
## Software distribution restrictions
We are restricted from distributing/including the server software in our Docker image. Minecraft server [properties](https://minecraft.fandom.com/wiki/Server.properties) (eg. creative vs. survival mode) are set on a local config file. Finally, the EULA must be accepted before the server is started.

The above requires us to download and install the server software, modify server properties, accept the EULA, then start the server in a programmatic / fully-automated fashion (no manual human intervention). The following was implemented to meet these requirements:

  * `.\docker\run-bds.sh` was developed to execute required tasks via CLI

    * Accept EULA 
      <p align="center">
        <img src="../_img/mvm_script_eula.png" width=500>
      </p>
        
    * Download Minecraft server software and install
      <p align="center">
        <img src="../_img/mvm_script_dlbds.png" width=500>
      </p>
    * Modify server properties
      <p align="center">
        <img src="../_img/mvm_script_server_props.png" width=500>
      </p>
    * Start server
      <p align="center">
        <img src="../_img/mvm_script_start_server.png" width=500>
      </p>
    * `.\docker\DockerFile` was developed to copy the bootstrap script into container image and setup for startup execution.
    
      ```
      COPY ../docker/run-bds.sh /opt/
      ...
      ENTRYPOINT [ "/bin/bash", "/opt/run-bds.sh" ]
      ```
## Stateful app requirment
Minecraft server is a stateful app, game data (user and world saved states) is saved on mounted volumes. Data loss is inevitable if stored locally due to the ephemeral nature of container storage.

The above requires us to provide stable, persistent data storage to our containerized app via  Persistent Volumes (PVs). 

[Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) is used to provide persistent and stable data storage to the running container in all deployment models. 
  * This storage is managed manually if using ACI. 
  * AKS minimizes management overhead, by dynamically manage storage for us.
    
