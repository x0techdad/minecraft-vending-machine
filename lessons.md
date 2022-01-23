# Lessons learned
<p align="center">
  <img src="./images/mvm_logo.gif" width="400"></br>
  <a href="./README.md">Home</a>
</p>

## Software distribution restrictions
* Distributing Minecraft server software is prohibited 
* Server [properties](https://minecraft.fandom.com/wiki/Server.properties) (e.g. creative vs. survival mode) are set via local config file: `/data/server.properties`
* App is prevented from starting if EULA is not accepted

The above requires us to download and install the server software, modify server properties, accept the EULA, then start the server app in a programmatic / fully-automated fashion (no manual human intervention). The following was implemented to meet these requirements:

  * `.\scripts\run_bds.sh` was developed to execute required tasks via CLI

    * Accept EULA 
      <p align="center">
        <img src="./images/mvm_script_eula.png" width=500>
      </p>
        
    * Download Minecraft server software and install
      <p align="center">
        <img src="./images/mvm_script_dlbds.png" width=500>
      </p>
    * Modify server properties
      <p align="center">
        <img src="./images/mvm_script_server_props.png" width=500>
      </p>
    * Start server
      <p align="center">
        <img src="./images/mvm_script_start_server.png" width=500>
      </p>
    * `.\deploy\Dockerfile.mc_bds` was developed to copy the bootstrap script into container image and setup for startup execution.
    
      ```
      COPY run_bds.sh /opt/
      ...
      ENTRYPOINT [ "/bin/bash", "/opt/run_bds.sh" ]
      ```
## Stateful app requirement
Minecraft server is a stateful app and saves its game data (user and world saved states) on mounted volumes. Data loss is inevitable if stored locally due to the ephemeral nature of container storage.

The above requires us to provide stable, persistent data storage to our containerized app via  Persistent Volumes (PVs). 

[Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-introduction) is used to provide persistent and stable data storage to the running container in all deployment models. PV storage management is manual if using ACI and dynamic if using AKS


