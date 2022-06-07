provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_sqs_queue" "my_other_sqs" {
  name = "my-rha-test-sqs-2"
}
