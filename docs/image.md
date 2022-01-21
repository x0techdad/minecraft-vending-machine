<!---##### Custom Docker Image
    ### Image Build
  Follow these steps if you'd like to build and publish your container image (not as hard as it sounds).
  1. Install Docker on your machine
      * [Windows](https://docs.docker.com/desktop/windows/install/)
      * [*nix](https://docs.docker.com/engine/install/)
      * [*macOS](https://docs.docker.com/desktop/mac/install/)
  2. Create a [Docker Hub subscription](https://hub.docker.com/)
      * Required to host your image.
      * Make sure to verify your email, otherwise you will not be able to upload your image. 
  3. In your CLI navigate to the `.\docker` directory
  4. Build the docker image using `.\docker\DockerFile`. Assign an image name and tag, its recommended you use a build version number for tag. 

      `docker login`

      `docker build --pull --rm -f "DockerFile" -t <image name>:<tag> "."`
      
      * Real-world example\
        `docker build --pull --rm -f "DockerFile" -t minecraft-bds:0.5 "."`
  5. Found this cool new integration when building the latest version, container vulnerabliity scanning integrated right into the build pipeline, made possible by [Synk!](https://docs.snyk.io/products/snyk-container/image-scanning-library/docker-hub-image-scanning)

      <p align="center">
        <img src="./_img/mvm_docker_scan.png" width=500>
      </p>
      <p align="center">
        <img src="./_img/mvm_docker_scan_01.png" width=500>
      </p>
      <p align="center">
        <img src="./_img/mvm_docker_scan_02.png" width=500>
      </p>

      * To run an assessment on your image and output the results to a local file, specify your image details\
        `docker scan <image name>:<tag> > .\_vul_scan_out.txt`

      * Real-world example\
        `docker scan minecraft-bds:0.5 > .\_vul_scan_out.txt`

      * At this point you can address any vulnerabilites found and re-package the image, or accept risk and move on. 

  5. Test image locally. 
      * Specify required contianer environemnt variables.  
      * To download the latest version of Minecraft server, specify 'latest', otherwise specify the full version number, eg. `1.18.2.03`. 

        `docker run --name test --rm -it -e debug=TRUE -e eula=TRUE -e bds_version=1.18.2.03 <image name>:<tag>`

      * Real-world example\
          `docker run --name test --rm -it -e debug=TRUE -e eula=TRUE -e bds_version=1.18.2.03 minecraft-bds:0.5`
      
      * If all is good, you should see the following output in your CLI. Were looking at the `Info` logs Minecraft outputs.

        <p align="center">
          <img src="./_img/mvm_docker_test.png" width=500>
        </p>

      * Stop test\
        `^C`\
        `docker stop test`
  6. Tag and push/upload image to Docker Hub

      `docker tag <image name>:<tag> <namespace>/<image name>:<tag>`

      `docker push <namespace>/<image name>:<tag>`
    
      * Real-world example\
        `docker tag minecraft-bds:0.5 cooltechdad/minecraft-bds:0.5`

        `docker push cooltechdad/minecraft-bds:0.5`
      
      * After you image is pushed, its public URI will be, please take note of this, you'll need it during deployment: `docker.io/<namespace>/<image name>:<tag>`

      * The latest version of CoolTechDad's image for this project
        * Source `docker.io/cooltechdad/minecraft-bds:0.5`
        * URL https://hub.docker.com/repository/docker/cooltechdad/minecraft-bds
