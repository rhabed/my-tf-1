# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket = "my-rha-tf-state-bucket"
    key    = "./terraform_sqs2.tfstate"
    region = "ap-southeast-2"
  }
}
