

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
        number_of_host = "trigger"
    }
    provisioner "local-exec" {
        command = <<EOT
        aws ec2 describe-regions --region ${var.region};
        aws ec2 allocate-hosts --instance-family \"a1\" --availability-zone ${random_shuffle.az.result[0]} --auto-placement \"off\" --host-recovery \"on\" --quantity ${var.host_count} --region ${var.region}
        EOT
    }
}