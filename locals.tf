locals {
  scaling = join(".", [var.action, var.host_count])
  allocate_host_cmd = var.action == "allocate" ? "aws ec2 allocate-hosts --instance-family \"a1\" --availability-zone ${random_shuffle.az.result[0]} --auto-placement \"off\" --host-recovery \"on\" --quantity 1 --region ${var.region}" : ""
  release_host_cmd  = var.action == "release" ? "aws ec2 release-hosts --host-ids ${var.host_ids} --region ${var.region}" : ""
  cmd =  "${coalesce(local.allocate_host_cmd,local.release_host_cmd, "")}"
}
