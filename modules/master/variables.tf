variable master_security_group_id {
   description = "the id of the security group for the masters"
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
    description = "the trget group arn for the mco group"
    type = string
}

variable "master_instance_profile_name" {
    description = "name of the master instance profile"
    type = string
}

variable subnet_ids {
  description = "list of subnet ids"
  type = list
}

variable infra_name {
    description = "the infrastructure name"
    type = string
}

variable "master_ignition" {
    description = "ignition for masters"
    type = string
}