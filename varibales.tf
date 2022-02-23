variable cluster_name {
  description = "the cluster name"
  type = string
  default = "private-cluster"
}

variable infra_name {
  description = "the cluster-name plus some random string"
  type = string
  default = "private-cluster-ncdkckdldc"
}

variable vpc_cidr_block {
    description = "the cidr block of the vpc where to deploy clusters"
    type = string
    default = "10.0.0.0/16"
}

variable "clusters" {
  description = "a map representing the clusters name"
  type        = map
  default = {
    "automated-1" : {
        "private_subnets" : {
            "us-east-1a": "10.0.1.0/24",
            "us-east-1b": "10.0.2.0/24",
            "us-east-1c": "10.0.3.0/24",
        },
        "public_squid_subnets" : {
            "us-east-1a": "10.0.4.0/24",
            "us-east-1b": "10.0.5.0/24",
            "us-east-1c": "10.0.6.0/24",
        }
    }
  }
}
locals {
  private_subnets = flatten([
    for cluster_name, attr in var.clusters: [
      for az, cidr in attr.private_subnets : {
        availability_zone = az
        name = format("%s-private-subnet-%s", cluster_name, az)
        cidr =  cidr
        cluster_name = cluster_name
      }
    ]
  ])

  public_squid_subnets = flatten([
    for cluster_name, attr in var.clusters: [
      for az, cidr in attr.public_squid_subnets : {
        availability_zone = az
        name = format("%s-private-subnet-%s", cluster_name, az)
        cidr =  cidr
        cluster_name = cluster_name
      }
    ]
  ])

  created_private_subnets = flatten([
      for _, subnet in aws_subnet.private_subnet : {
          subnet = subnet
      }
  ])
}
