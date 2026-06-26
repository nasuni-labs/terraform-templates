variable "security_group_1" {
    description = "A security group that one or more resources will join upon being terraformed."
    default = "sg-xxxxxxxxxxx"
    type = string
}
# May create additional security group variables (they require different names)
# depending on whether you are deploying to more than one region.

variable "subnet" {
    description = "A subnet that one or more resources will join upon being terraformed"
    default = "subnet-xxxxxxxx"
    type = string
}
# May create additional subnet variables (they require different names)
# depending on whether you are deploying to more than one region.

variable "nmc_machine_type" {
    description = "The default machine type of the management console"
    default = "c6i.2xlarge"
    type = string
}

# Disk sizes, disk types, and machine types can and should be modified depending on your specifications.
# Disk types are listed in the edge.tf and main.tf
variable "nmc_disk_size" {
    description = "The size of the NMC root volume"
    default = "32"
    type = string
}

variable "edge_machine_type" {
    description = "The default machine type of the edge appliance"
    default = "c6i.2xlarge"
    type = string
}

variable "root_size" {
    description = "The default root disk size of the Nasuni Edge Appliance"
    default = "64"
    type = string
}

variable "cow_size" {
    description = "The defualt COW (copy on write) Disk size of the Nasuni Edge Appliance"
    default = "64"
    type = string
}

variable "cache_size" {
    description = "The default cache disk size of the Nasuni edge appliance"
    default = "256"
    type = string
}