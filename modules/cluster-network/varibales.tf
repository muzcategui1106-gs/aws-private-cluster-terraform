variable vpc_id {
  description = "the vpc cidr where the cluster will live"
  type = string
}

variable cluster_name {
  description = "the cluster name"
  type = string
}

variable "subnets" {
  description = "a map representing the clusters name"
  type  = map
}

variable "s3_gateway_endpoint_id" {
  description = "the id of the s3 vpc gateway endpoint"
  type = string
}