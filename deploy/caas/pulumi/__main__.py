"""An Azure RM Python Pulumi MVM Program"""

#from ast import Name
#from asyncio import protocols
#from inspect import TPFLAGS_IS_ABSTRACT
#from pickle import TRUE
#from sys import prefix
#from unicodedata import name

#from pkg_resources import safe_name
import pulumi
from pulumi_azure_native import storage
from pulumi_azure_native import resources
from pulumi_azure_native import containerinstance
from variables import *

#Create resource names
rg_name = "rg-cooldad-mvm-aci"
resource_name_prefix = "pydadmvm"
sa_name = "sta" + resource_name_prefix + deployment_unique_string
aci_name = "aci" + resource_name_prefix + deployment_unique_string

# Create an Azure Resource Group
resource_group = resources.ResourceGroup(
    rg_name,
    resource_group_name=rg_name,
    location=region)

# Create an Azure Storage Account
storage_account = storage.StorageAccount(sa_name + "001",
    resource_group_name=resource_group.name,
    account_name=sa_name.lower(),
    sku=storage.SkuArgs(
        name=storage.SkuName.PREMIUM_LRS,
    ),
    kind=storage.Kind.FILE_STORAGE)

# Create An Azure Storage Account File Share
file_share = storage.FileShare(sa_name + "/file share",
    account_name=storage_account.name,
    enabled_protocols="SMB",
    resource_group_name=resource_group.name,
    share_name="mvm-share",
    share_quota=100)

# Grab The Azure Storage Account Primary Key
primary_key = storage.list_storage_account_keys_output(
    resource_group_name=resource_group.name,
    account_name=storage_account.name
).keys[0].value

# Create An Azure Container Instance
container_group = containerinstance.ContainerGroup(aci_name + "001",
    container_group_name=aci_name,
    containers=[containerinstance.ContainerArgs(
        command=[],
        environment_variables=minecraft_env_settings,
        image=docker_image_uri,
        name="mvm-aci-server",
        ports=[containerinstance.ContainerPortArgs(
            port=19132,
            protocol = "UDP"
        )],
        resources=containerinstance.ResourceRequirementsArgs(
            requests=containerinstance.ResourceRequestsArgs(
                cpu=1,
                memory_in_gb=2,
            ),
        ),
        volume_mounts=[
            containerinstance.VolumeMountArgs(
                mount_path="/data",
                name="pv001",
                read_only=False,
            )
        ],
    )],
    ip_address=containerinstance.IpAddressArgs(
        dns_name_label=aci_name.lower(),
        ports=[containerinstance.PortArgs(
            port=19132,
            protocol="UDP",
        )],
        type="Public",
    ),
    os_type="Linux",
    resource_group_name=resource_group.name,
    volumes=[
        containerinstance.VolumeArgs(
            azure_file=containerinstance.AzureFileVolumeArgs(
                share_name="mvm-share",
                storage_account_key=primary_key,
                storage_account_name=storage_account.name,
            ),
            name="pv001",
        )
    ]
)

# Export The Azure Container Name and Pubic IP address
pulumi.export("Container Name", container_group.name)
pulumi.export("Container IP Address", container_group.ip_address.apply(lambda ip: ip.ip))