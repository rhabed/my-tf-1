variable "region" {
  description = "The Region that we will be building the module in"
  type        = string
  default     = "ap-southeast-2"
}

variable "host_count" {
  description = "Numer of Hosts"
  type        = number
  default     = 1
}

variable "action" {
  description = "Allocate or release dedicated hosts"
  type        = string
  default     = "nodeployment"
}

variable "host_ids" {
  description = "List of host ids to release"
  type = string
  default = ""
}