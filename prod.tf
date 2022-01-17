variable "whitelist" {
    type = list(string)
} 
variable "web_image_id" {
    type = string
}       
variable "web_desired_capacity" {
    type = number
}       
variable "web_max_size" {
    type = number
}       
variable "web_min_size" {
    type = number
}   

provider "aws" {
    profile = "rhatf"
    region = "ap-southeast-2"
}

variable "webserver_ami" {
    type = string
    default = "ami-0a4f5cadb53a98604"
}

## Check dynamic data with filtering
data "aws_ami" "weberver_ami" {
    most_recent =  true
    owners = ["self"]
    tags = {
        Name = "webserver"
        Deploy = "true"
    }
}

resource "aws_s3_bucket" "prod_my-tf-course" {
    bucket = "my-rha-tf-course"
    acl    = "private"
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default_az1" {
    availability_zone = "ap-southeast-2a"
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_default_subnet" "default_az2" {
    availability_zone = "ap-southeast-2b"
    tags = {
        "Terraform" : "true"
    }
}


resource "aws_security_group" "prod_web" {
    name = "prod_web"
    description =  "allow http and https inbound and all egress"

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = var.whitelist
    }

    ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = var.whitelist
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = var.whitelist
    }

    tags = {
        "Terraform" : "true"
    }
}

resource "aws_instance" "prod_web" {
    count                  = 2
    ami                    = var.web_image_id
    instance_type          = "t2.nano"
    vpc_security_group_ids = [
        aws_security_group.prod_web.id
    ]
    tags = {
        "Terraform" : "true"
    }
}

resource "aws_eip_association" "prod_web" {
    instance_id   = aws_instance.prod_web.0.id
    allocation_id = aws_eip.prod_web.id 
}

resource "aws_elb" "prod_web" {
    name            = "prod-web"
    instances       = aws_instance.prod_web.*.id
    subnets         = [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
    security_groups =  [aws_security_group.prod_web.id]
    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
}

resource "aws_eip" "prod_web" {
    tags = {
        "Terraform": "true"
    }
}

resource "aws_launch_template" "prod_web" {
  name_prefix   = "prod_web"
  image_id      = var.webserver_ami
  instance_type = "t2.micro"
}

resource "aws_autoscaling_group" "prod_web" {
  vpc_zone_identifier =  [ aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id ]
  desired_capacity   = var.web_desired_capacity
  max_size           = var.web_max_size
  min_size           = var.web_min_size

  launch_template {
    id      = aws_launch_template.prod_web.id
    version = "$Latest"
  }
  tag {
       key =  "Terraform"
       value = "true"
       propagate_at_launch = true
    }
}

resource "aws_autoscaling_attachment" "prod_web" {
  autoscaling_group_name = aws_autoscaling_group.prod_web.id
  elb                    = aws_elb.prod_web.id
}