data "aws_vpc" "openshift" {
  id = var.vpc_id
}

data "aws_internet_gateway" "vpc_igw" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}