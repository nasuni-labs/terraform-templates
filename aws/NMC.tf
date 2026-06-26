data "aws_ami" "aminmc1" {
  # A lookup function for the most recently released Nasuni Management Console AMI
  provider    = aws.us-east-1
  owners      = ["258514446814"]
  most_recent = true
  filter {
    name   = "name"
    values = ["Nasuni NMC*"]
  }
}

resource "aws_instance" "instancenmc1" {
  provider      = aws.us-east-1
  ami           = data.aws_ami.aminmc1.id
  instance_type = var.nmc_machine_type
  tags = {
    Name = "A_Name_For_The_Machine"
  }
  key_name               = "KeyName"
  # AWS machines, when deployed from the web, usually have a .pem file associated with them.
  # It is not strictly necessary, but may be included above
  subnet_id              = var.subnet
  vpc_security_group_ids = [var.security_group_1]
  # Security group ids are a list, as there may be more than one of them if you wish.
  root_block_device {
    volume_size = var.nmc_disk_size
    volume_type = "gp3"
    
  }
}
