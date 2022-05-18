

resource "aws_ec2_host" "test" {
  count = var.host_count
  instance_type     = "a2.medium"
  availability_zone = "ap-southeast-2a"
  host_recovery     = "on"
  auto_placement    = "on"
  tags = {
    Name  = "ec2-host-${count.index + 1}"
  }
}
