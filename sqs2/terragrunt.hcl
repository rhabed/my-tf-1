# stage/terragrunt.hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "my-rha-tf-state-bucket"

    key = "${path_relative_to_include()}/terraform_sqs2.tfstate"
    region         = "ap-southeast-2"
  }
}
