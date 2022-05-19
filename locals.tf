locals {
  scaling = "deploy"
  allocate_host_cmd = "aws ec2 allocate-hosts --instance-family \"a1\" --availability-zone ${random_shuffle.az.result[0]} --auto-placement \"off\" --host-recovery \"on\" --quantity ${var.host_count} --region ${var.region}"
}
