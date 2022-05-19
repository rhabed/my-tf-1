

# resource "aws_ec2_host" "test" {
#   instance_type     = "a1.medium"
#   availability_zone = "ap-southeast-2a"
#   host_recovery     = "on"
#   auto_placement    = "on"

# }
resource "random_shuffle" "az" {
  input        = ["ap-southeast-2a", "ap-southeast-2b"]
  result_count = 1
}

resource "null_resource" "ec2_host_fleet" {
    triggers = {
        trigger = var.scaling
    }
    provisioner "local-exec" {
        command = var.allocate_host_cmd
    }
}