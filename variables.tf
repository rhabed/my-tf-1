variable "region" {
  description = "The Region that we will be building the module in"
  type        = string
  default     = "ap-southeast-2"
}

variable "host_count" {
  description = "The Region that we will be building the module in"
  type        = number
  default     = 1
}

variable "scaling" {
  description  = "Scale In or Out the number of hosts"
  type = string
  default = "deploy"
}

variable "allocate_host_cmd" {
  description = "Allocate cmd"
  type = string
  default = "aws ec2 allocate-hosts --instance-family \"a1\" --availability-zone ${random_shuffle.az.result[0]} --auto-placement \"off\" --host-recovery \"on\" --quantity ${var.host_count} --region ${var.region}"
}
