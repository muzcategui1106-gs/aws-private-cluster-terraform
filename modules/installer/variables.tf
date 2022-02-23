variable vpc_id {
  description = "the vpc cidr where the cluster will live"
  type = string
}

variable "cluster_name" {
  description = "cluster_name"
  type = string
}

variable "subnet_ids" {
  description = "a list of private subnets where the cluster will be located"
  type = list
}