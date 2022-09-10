terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# module "my-s3-bucket" {

#   source = "terraform-aws-modules/s3-bucket/aws"
#   bucket = "my-rha-s3-test-123"
#   acl    = "private"
#   versioning = {
#     enabled = false
#   }
# }

# resource "aws_s3_bucket_notification" "bucket_notification" {
#   bucket = module.my-s3-bucket.s3_bucket_id

#   topic {
#     topic_arn     = aws_sns_topic.topic.arn
#     events        = ["s3:ObjectCreated:*"]
#     filter_suffix = ".log"
#   }
# }

# resource "aws_sns_topic" "topic" {

#   name              = "s3-event-notification-topic"
#   kms_master_key_id = "alias/alias/rha"

#   policy = <<POLICY
# {
#     "Version":"2012-10-17",
#     "Statement":[{
#         "Effect": "Allow",
#         "Principal": { "Service": "s3.amazonaws.com" },
#         "Action": "SNS:Publish",
#         "Resource": "arn:aws:sns:*:*:s3-event-notification-topic"
#     }]
# }
# POLICY
# }

# resource "aws_sns_topic_subscription" "email-target" {
#   topic_arn = aws_sns_topic.topic.arn
#   protocol  = "email"
#   endpoint  = "rhabed@gmail.com"
# }

resource "aws_kms_alias" "a" {
  name          = "alias/my-key-alias-2"
  target_key_id = aws_kms_key.a.key_id
}

resource "aws_kms_alias" "a2" {
  name          = "alias/my-key-alias-3"
  target_key_id = aws_kms_key.a.key_id
}

resource "aws_kms_key" "a" {}
