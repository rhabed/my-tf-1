
variable "is_true" {
    default = true
}

variable "param_name" {
    default = "name"
}

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.is_true ? data.local_file.anzx-kms-key-arn-value.content : "robert_abed"

  ami                    = "ami-0c6120f461d6b39e9"
  instance_type          = "t3.micro"
  key_name               = "my-rha-key"
  monitoring             = false
  vpc_security_group_ids = ["sg-0d550d4076708b997"]
  subnet_id              = "subnet-bfd877e6"
  # user_data              = data.user_script
  user_data = templatefile("./user_data.sh",  jsondecode(file("./input.json")))
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "null_resource" "anzx-kms-key-arn" {
  provisioner "local-exec" {
    command = "aws ssm get-parameter --name /my-rha-params/${var.param_name} --query 'Parameter.Value' --output text > ./kms-key-arn.txt"
  }
}

### -------------------------------------------------------
### ANZx local file where ARN value is saved
### -------------------------------------------------------
data "local_file" "anzx-kms-key-arn-value" {
  filename   = "./kms-key-arn.txt"
  depends_on = ["null_resource.anzx-kms-key-arn"]
}