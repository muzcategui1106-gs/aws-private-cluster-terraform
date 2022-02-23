locals {
  private_subnets = flatten([
    for az, cidr in var.subnets : {
      availability_zone = az
      name = format("%s-private-subnet-%s", var.cluster_name, az)
      cidr =  cidr
      cluster_name = var.cluster_name
    }
  ])

  s3_prefixes = sort([for p in data.aws_ec2_managed_prefix_list.s3_gateway_prefix.entries : "${p.cidr}"])
}