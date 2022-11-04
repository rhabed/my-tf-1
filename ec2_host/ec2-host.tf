
variable "az" {
    default = ["ap-southeast-2a", "ap-southeast-2c"]
}

variable "subnet_ids" {
    default = ["subnet-fb2cb79f", "subnet-bfd877e6"]
}

resource "aws_ec2_host" "host" {
    count = 2
    instance_family = "m4"
    host_recovery =  "off"
    auto_placement = "off"
    availability_zone = var.az[count.index % 2]
}

resource "aws_instance" "instance" {
    count = 2
    ami = data.aws_ami.ubuntu.id
    instance_type = "m4.large"
    availability_zone = var.az[count.index % 2]
    subnet_id = var.subnet_ids[count.index % 2]
    host_id = aws_ec2_host.host[count.index].id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}