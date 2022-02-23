variable vpc_id {
  description = "the vpc cidr where the cluster will live"
  type = string
}

variable cluster_name{
  description = "cluster name"
  type = string
}

variable "subnets" {
  description = "a map representing the clusters name"
  type        = map
}