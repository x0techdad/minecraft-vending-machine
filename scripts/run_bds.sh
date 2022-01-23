#!/bin/bash

set -eo pipefail

if [[ ${debug^^} = TRUE ]]; then
  set -x
  curl_args=(-v)
  echo "DEBUG: running as $(id -a) with $(ls -ld /data)"
fi

if [[ ${eula^^} != TRUE ]]; then
  echo
  echo "EULA must be set to TRUE to indicate agreement with the Minecraft End User License"
  echo "See https://minecraft.net/terms"
  echo
  echo "Current value is '${eula}'"
  echo
  exit 1
fi

function test_url {
  if ! curl -Is $1 | head -1 | grep 'HTTP/2 200' > /dev/null; then
  echo "ERROR connectivity to $1 failed"
  exit 2
  fi
}

if [[ ${bds_version} == *latest* ]]; then
  download_url=$(curl -s https://mc-bds-helper.vercel.app/api/latest)
else
  download_url="https://minecraft.azureedge.net/bin-linux/bedrock-server-"${bds_version}".zip"
fi

test_url ${download_url}
tmp_zip=/tmp/$(basename "${download_url}")

echo "Downloading specified version of server software..."
if ! curl "${curl_args[@]}" -o ${tmp_zip} -fsSL ${download_url}; then
echo "ERROR failed to download from ${download_url}"
exit 2
fi

echo "Extracting server software..."
unzip -n -q ${tmp_zip}
rm ${tmp_zip}

echo "Setting server.properties..."
declare -a options
options=("server-name" "gamemode" "difficulty" "allow-cheats" "max-players" "online-mode" "white-list" "view-distance" "tick-distance" "player-idle-timeout" "max-threads" "level-name" "level-seed" "default-player-permission-level" "texturepack-required" "content-log-file-enabled" "compression-threshold" "server-authoritative-movement" "player-movement-score-threshold" "player-movement-distance-threshold" "player-movement-duration-threshold-in-ms" "correct-player-movement")
for opt in ${options[@]}
do
    env="${opt}"
    env="${env//\-/_}"

    if [ "${!env}" != "" ];
    then
        echo "SETTING minecraft option $opt with $env=\"${!env}\""
        sed -i "s/^$opt=.*$/$opt=${!env}/" /data/server.properties
    else
        echo "Not set $opt with $env"
    fi
done

echo "Applied server.properties:"
cat /data/server.properties

export LD_LIBRARY_PATH=.

echo "Starting Minecraft server..."
exec ./bedrock_server