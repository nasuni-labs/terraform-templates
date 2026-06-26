data "aws_ami" "amiea1" {
  # A lookup function for the most recently released Nasuni Edge AMI
  provider    = aws.us-east-1
  owners      = ["258514446814"]
  # The Owner number makes sure we're only searching for nasuni machines
  most_recent = true
  filter {
    name   = "name"
    values = ["Nasuni Filer*"]
  }
}

resource "aws_instance" "instanceea1" {
  provider      = aws.us-east-1
  ami           = data.aws_ami.amiea1.id
  instance_type = var.edge_machine_type
  tags = {
    Name = "A_Name_For_the_machine"
  }
  key_name               = "KeyName"
  # Similarly to the NMC, The above line may be omitted.
  # But you may include the name of a pem key you wish to deploy with,
  # as is often done with web deployments
  subnet_id              = var.subnet
  vpc_security_group_ids = [var.security_group_1]
  # Security group ids are a list, as there may be more than one of them if you wish.

  root_block_device {
    volume_size = var.root_size
    volume_type = "gp3"
    # Nasuni recommends either gp3 or io2 disks, depending on workload.
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = var.cow_size
    volume_type = "gp3"
  }
  ebs_block_device {
    device_name = "/dev/sdc"
    volume_size = var.cache_size
    volume_type = "gp3"
  }
  ebs_block_device {
    device_name = "/dev/sdd"
    volume_size = var.cache_size
    volume_type = "gp3"
  }
  # May include more than one Cache disk.
}


