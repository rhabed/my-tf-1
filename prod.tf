

# resource "aws_ec2_host" "test" {
#   instance_type     = "a1.medium"
#   availability_zone = "ap-southeast-2a"
#   host_recovery     = "on"
#   auto_placement    = "on"

# }

resource "null_resource" "ec2_host_fleet" {
    triggers = {
        number_of_host = "my_robert"
    }
    provisioner "local-exec" {
        command = "aws ec2 allocate-hosts --instance-family \"a1\" --availability-zone \"ap-southeast-2a\" --auto-placement \"off\" --host-recovery \"on\" --quantity ${var.host_count} --region ${var.region}"
    }
}