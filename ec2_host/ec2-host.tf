
variable "az" {
    default = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "subnet_ids" {
    default = ["subnet-fb2cb79f", "subnet-9175f7e7"]
}

resource "aws_ec2_host" "host" {
    count = 2
    instance_type = "mac1.metal"
    host_recovery =  "off"
    auto_placement = "off"
    availability_zone = var.az[count.index % 2]
}

resource "aws_instance" "instance" {
    count = 2
    ami = "ami-0a99fd5afc0ce4d09" 
    #data.aws_ami.ubuntu.id
    instance_type = "mac1.metal"
    availability_zone = var.az[count.index % 2]
    subnet_id = var.subnet_ids[count.index % 2]
    host_id = aws_ec2_host.host[count.index].id
}

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }