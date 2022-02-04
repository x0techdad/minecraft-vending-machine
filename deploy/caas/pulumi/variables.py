# Azure Resource Variables
region = "eastus2"
deployment_unique_string = "jw9r"
docker_image_uri = "docker.io/cooltechdad/minecraft-bds:0.6"

# Minecraft Environment Variables
minecraft_env_settings=[
    {"name" : 'debug', "value" : "true"},
    {"name" : 'eula', "value" : "TRUE"},
    {"name" : 'bds_version', "value" : "1.18.2.03"},
    {"name" : 'level_name', "value" : "Bedrock level"},
    {"name" : 'gamemode', "value" : "creative"},
    {"name" : 'allow_cheats', "value" : "false"},
    {"name" : 'max_players', "value" : "1000"},
    {"name" : 'server_authoritative_movement', "value" : "server-auth-with-rewind"}
]
