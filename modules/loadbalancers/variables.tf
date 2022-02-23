variable vpc_id {
  description = "the vpc cidr where the cluster will live"
  type = string
}

variable infra_name {
  description = "the name of the infrastructure"
  type = string
}

variable subnet_ids {
  description = "list of subnet ids"
  type = list
}

variable "hosted_zone_id" {
  description = "the id of the private hosted zone onto which deploy the cluster"
  type = string
}