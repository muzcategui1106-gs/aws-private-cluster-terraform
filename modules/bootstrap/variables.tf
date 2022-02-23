variable vpc_id {
  description = "the vpc cidr where the cluster will live"
  type = string
}

variable master_security_group_id {
   description = "the id of the security group for the masters"
  type = string
}

variable bootstrap_location {
  description = "the location of the boostrap ignition file"
  type = string
}

variable boostrap_subnet_id {
  description = "subnet for bootstrap node"
  type = string
}

variable "external_api_target_group_arn" {
    description = "the trget group arn for the external api group"
    type = string
}

variable "internal_api_target_group_arn" {
    description = "the trget group arn for the internal api group"
    type = string
}

variable "internal_api_mco_target_group_arn" {
    description = "the trget group arn for the etcd group"
    type = string
}