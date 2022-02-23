locals {
  public_squid_subnets = flatten([
    for az, cidr in var.subnets: {
      availability_zone = az
      name = format("%s-public-squid-subnet-%s", var.cluster_name, az)
      cidr =  cidr
      cluster_name = var.cluster_name
    }
  ])
}
