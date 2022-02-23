variable infra_name {
    description = "the infrastructure name"
    type = string
}

variable "hosted_zone_id" {
  description = "the id of the private hosted zone onto which deploy the cluster"
  type = string
}