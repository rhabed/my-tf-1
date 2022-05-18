

resource "aws_ec2_host" "test" {
  instance_type     = "a2.medium"
  availability_zone = "ap-southeast-2"
  host_recovery     = "on"
  auto_placement    = "on"
}