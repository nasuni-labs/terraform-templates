variable "resource_group" {
    description = "Resource Group that is used with"
    default = "yourresourcegrouphere"
    type = string
}

variable "azure_subnet"{
    description = "subnet in which to create the network interface"
    default = "yoursubnetidhere"
    # "/subscriptions/{subscriptionid}/resourceGroups/{resourcegroupid}/providers/Microsoft.Network/virtualNetworks/{vnet-name}/subnets/{yoursubnetname}"
    # The full subnet Id looks like the above. It is supposed to be long.
    # NOTE: This value can be found in the Resource JSON of the virtual network your subnet is in in the azurewebclient
    # If your subnet is also in terraform, this can be pulled from that resource from the subnet.id variable
    # You can also find it programmatically by running this command
    # """az network vnet subnet list --resource-group "Yourresourcegroupname" -n "yoursubnetname" --vnet-name "yourvnetname" """"
    type = string
}

variable "location"{
    description = "region code for where you want the VM to deploy. Defaults to centralus,"
    default = "centralus"
    type = string
}

variable "machine_size"{
    description = "the default machine type for a Nasuni Edge Appliance. Defaults to a small working size"
    default = "Standard_D8s_v3"
}

variable "cache_size"{
    description = "the default cache size for a Nasuni Edge Appliance. Defaults to a small serviceable size"
    default = "256"
}

variable "cow_size"{
    description = "the default cow (Copy-on-write) disk size for a Nasuni Edge Appliance. Defaults to a small serviceable size"
    default = "64"
}