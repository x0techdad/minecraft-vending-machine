# Minecraft Vending Machine
<p align="center">
  <img src="./images/mvm_logo.gif" width="400"></br>
  <a href="#intro">Intro</a> |
  <a href="#overview">Overview</a> |
  <a href="#setup">Setup</a> 
</p>

## Intro
  Hello. This project was initially developed out of a need to quickly deploy and re-deploy my own [Minecraft](https://minecraft.fandom.com/wiki/Minecraft_Wiki) servers, in the cloud, as cheap as possible*. The servers are then used in various scenarios; work projects, family gaming, kid coding camp sessions, and so dad can nerd out with his friends. :nerd_face:
  
  The project is also being used to demo, teach, learn, and play with the cool cloud tech listed in the [tech](#tech) section. 
  
  Welcome! 
  * If you want a lot more project background and technical overview, continue to the next section.

  * If you want to jump into the deep end, I like your style, head over to the [setup](#setup) section. 

  * If you'd like to contribute to code, you are awesome, please check out the [contribute](#contribute) section.
  
  * Project custodian contact details located in the [meta](#meta) section.

    * Share feedback and comments via listed socials
    * Submit issues, bugs, feature requests via [GitHub](https://github.com/cool-tech-dad/minecraft-vending-machine/issues)
  
  * Get help at the [CoolTechDad.Cloud Discord](https://discord.gg/aCnzN2QsQE) 

  ### * Only the first 30 days or $200 of cloud consumption are free. 💰
  Stop or delete cloud compute resources when not in use to save on runtime costs. A [Minecraft client](https://www.minecraft.net/en-us/get-minecraft#) is required to connect to the server and play, DO NOT purchase/use the Java client, more on this in the next section.  

## Overview
  [Minecraft server](https://minecraft.fandom.com/wiki/Server) is developed in two languages; C++ ([Bedrock](https://minecraft.fandom.com/wiki/Bedrock_Edition)) and [Java](https://minecraft.fandom.com/wiki/Server) and packaged as a single executable (.exe). Due to licensing, we cannot distribute the software, meaning we'll need to download and install the binaries each time a new server is deployed. 

  We will be using the Bedrock edition for better cross-platform gameplay, and...uhh...yeaaah, anything but Java. 
  <p align="center">
    <img src="https://static.hiphopdx.com/2015/10/drake-hotline-bling-jacket-moncler.png" height="200">
  </p>

  As of now, the fastest method of deploying an app and its underlying runtime (OS, binaries, dependencies, etc.) is via [containers](https://www.docker.com/resources/what-container). A Docker image has already been packaged up and is [publicly available](https://hub.docker.com/repository/docker/cooltechdad/minecraft-bds) on Docker Hub; the base OS is [Ubuntu server](https://hub.docker.com/_/ubuntu/). The project uses this image by default during deployment, however, you can also create and use your own image following the steps in the [image build](#image-build) section.

  <p align="center">
    <img src="./images/mvm_docker_logo.png" width="400"></br>
  </p>

  Once we have our image, we need to load and launch it on some compute, attach persistent storage and a public network interface (Public IP), so our Minecraft clients can connect from anywhere :milky_way: via the Internet. That's where public cloud platforms, like Azure, come in very handy. The ease of use, speed of deployment, and scale capabilities of these platforms unlock very interesting possibilities for anyone willing to learn and use them. 

  Another benefit of public cloud platforms is that they usually provide us with a few different methods to build and host our applications, each with its benefits over the others and ideal use cases. 

  Included in the project is [Infrastructure as code (IaC)](https://youtu.be/WhWf48kcEXU) that is used to deploy your preffered public cloud compute infrastructure. Skip to the [setup](#setup) section to get started. In all scenarios:
  * Game data (server .exe, user, and world databases) is stored on SMB Azure Files shares. The required Azure storage account is deployed when using included IaC. 

  * The Minecraft server process runs as root, a task to change this is in the backlog.

  As of now, the project only supports Azure for compute and storage, we are looking to add support for other platforms in future versions.

  <p align="center">
    <img src="./images/mvm_azure_logo.png" width="400"></br>
  </p>

## Tech
  * [Minecraft Bedrock Dedicated Server (BDS)](https://minecraft.fandom.com/wiki/Bedrock_Dedicated_Server) 1.18.2.03
  * [Ubuntu server](https://hub.docker.com/_/ubuntu) 20.04
  * Infrastructure compute options:
    * Container as a Service (CaaS): [Azure Container Instance (ACI)](https://docs.microsoft.com/en-us/azure/container-instances/)
    * Kubernetes (K8S) 1.20.9: [Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/)
  * [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/what-is-azure-cli) 2.31.0.
    * A cross-platform tool used to manage Azure resources and connect to cloud services via the command line.
  * [CoolTechDad's Minecraft BDS image](https://hub.docker.com/repository/docker/cooltechdad/minecraft-bds) 0.5
  * [Docker Desktop](https://docs.docker.com/desktop/) 20.10 
    * If creating your own container image
  * Infrastructue deployment (IaC tool) options:
    * [Azure Bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep)
        * Platform-native, declarative domain-specific language (DSL) used to deploy and configure Azure resources via code.
    * [HashiCorp Terraform](https://www.terraform.io/intro)
        * The most popular 3rd party IaC tool
    * In my humble opinion, cloud-native interfaces usually provide better overall experiences, performance, keep project dependencies and costs down. However, the project also includes support for the most popular 3rd party offering. 

## Setup
  ### 1. Environment
  * [Clone](https://github.com/cool-tech-dad/minecraft-vending-machine) or [download](https://github.com/cool-tech-dad/minecraft-vending-machine/archive/refs/heads/main.zip) this project repo to your machine:
      * If you download, unzip the contents to a local directory. 
      * To clone, you'll need to already have or install [git](https://git-scm.com/downloads). 
  * Launch your preferred console and navigate to the `.\minecraft-vending-machine` directory 
  * Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli):
      * Windows

        `Invoke-WebRequest -Uri https://azcliprod.blob.core.windows.net/msi/azure-cli-2.31.0.msi -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi`

      * *nix (script runs on any flavor)

        `curl -L https://aka.ms/InstallAzureCli | bash` 

      * macOS

        `brew update && brew install azure-cli`

  * Install the CLI for your preferred cloud infrastructure / resource management tool:
      * [Azure Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli)
      * [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started)

  * Open a free Azure account, [create a PAYG subcription](https://azure.microsoft.com/en-us/free/):
      * If you are using a pre-existing Azure subscription, [verify](https://docs.microsoft.com/en-us/azure/role-based-access-control/check-access) that you have at least Owner role assigned at the subscription level.

  * Log into the Azure platform via CLI, set the context of Azure CLI to the correct subscription:

      `az login`

      `az account set --subscription <replace with sub name>`

      * To list all available subscriptions: `az account list`
      * To verify current context, important to do before each deployment: `az account show`

  ### 2. Deploy Server
  Pick and deploy your preffered cloud infrastructure pattern to host your Minecraft server on:
  #### <a href="./docs/aci.md">Azure Container Instance (ACI)</a> (fast, small, cheap)
  <!--* Sorry, currently developing the infra code to deploy this scenario, check back soon! Check out the AKS pattern below, the deployment has been cost optimized,  shouldnt ding your credits too bad to use for a few sessions of game play.-->
  * ACI is primarily used to launch isolated containers without the orchestration and management capabilities of a platform like K8S. 
  * ACI is a true CaaS, and usually a cheaper alternative to K8S and its platform-managed variants (AKS, GKE, EKS).
  #### <a href="./docs/aks.md">Azure Kubernetes Service (AKS)</a>  (scalable, fully-managed, production-ready)
  * AKS is primarily used to launch, orchestrate, and manage the entire lifecycle of containers. 


 ### 3. Connect
  * Its time play :video_game: ! 
  * Load up your favorite [Minecraft client](https://www.minecraft.net/en-us/get-minecraft#) (not Java!), add the server and connect:

    <p align="center">
      <img src="./images/mvm_success_animation.gif">
    </p>

    * Additional steps are required for Xbox clients, will be added in the next version.
  ### 4. Cleanup
  Cloud can get expensive fast, prevent surprise costs by forcibly deleting all resources when your done: 
  
  `az group list --query "[? starts_with(name, 'rg-cooldad-mvm')][].{name:name}" -o tsv | % {az group delete --resource-group $_ -y}`

  <p align="center">
    <img src="./images/it_was_all_a_dream.png" width=400>
  </p>

## Lessons learned
  <a href="./docs/aci.md">This doc</a> lists the gotchas and pitfalls we ran into when running Minecraft BDS in a container, and how we solved for each.
  
## Contribute
Please follow the instructions below if you'd like to contribute to the project:
1. Fork project\
  <https://github.com/cool-tech-dad/minecraft-vending-machine/fork>
2. Create your feature branch\
  `git checkout -b feature/foo_bar`
3. Commit your changes\
  `git commit -am 'Add some foo_bar'`
4. Push to the branch\
  `git push origin feature/foo_bar`
5. Create a new Pull Request

## Contributors
* CoolTechDad\
  Twitter: [@x0coolTechDad](https://twitter.com/x0cooltechdad)\
  GitHub: [@cool-tech-dad](https://github.com/cool-tech-dad)\
  Discord: x0coolTechDad#7007

* Ted Martin\
  GitHub: [TedMartin](https://github.com/tedmartn)\
  Discord: tedwreckz#0892

## Backlog
- [ ] Change server runtime context to a non-root user
- [ ] Add readiness probe to service spec 
- [ ] Add backup to the persistent data store (Azure Files)
- [ ] AKS with multiple node pools and Minecraft servers
- [ ] [Minecraft Education](https://education.minecraft.net/en-us/homepage) container image

## Change Log
0.5.0 Initial beta

[Distributed under the GNU V3 license](https://gnu.org/licenses)

## Sources
* Script : https://github.com/itzg/docker-minecraft-bedrock-server/blob/master/bedrock-entry.sh


