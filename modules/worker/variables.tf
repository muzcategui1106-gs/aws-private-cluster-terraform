variable worker_security_group_id {
   description = "the id of the security group for the masters"
  type = string
}

variable "worker_instance_profile_name" {
    description = "name of the worker instance profile"
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

variable "worker_ignition" {
    description = "ignition for workers"
    type = string
}