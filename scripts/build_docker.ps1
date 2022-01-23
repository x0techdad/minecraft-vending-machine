# PowerShell script to build custom Docker image from two Docker spec files

param ($gameDockerfile, $tag)

function add_to_dockerfile ($file) {
  if ($file) {
    get-content $file -force | `
    out-file Dockerfile -Append -Encoding utf8
  }    
}

new-item Dockerfile -ItemType file -force
add_to_dockerfile "..\Dockerfile.base"
add_to_dockerfile $gameDockerfile

docker build --pull --rm -f "Dockerfile" -t $tag .

