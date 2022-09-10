
variable "proxy_secret_arn" {
  type    = string
  default = "anzx_proxy_secret_arn"
}

data "amazon-secretsmanager" "proxy_username" {
  name = "${var.proxy_secret_arn}"
  key  = "username"
}

data "amazon-secretsmanager" "proxy_password" {
  name = "${var.proxy_secret_arn}"
  key  = "password"
}

locals {
  username_secret_value = jsondecode(data.amazon-secretsmanager.proxy_username.secret_string)["username"]
  password_secret_value = jsondecode(data.amazon-secretsmanager.proxy_password.secret_string)["password"]
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-linux-aws-1"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "var=1",
      "var2=$(echo $var)",
      "echo $var2", 
      "user=${local.username_secret_value}",
      "pass=${local.password_secret_value}",
      "echo $user",
      "echo $pass"
    ]
  } 
}
