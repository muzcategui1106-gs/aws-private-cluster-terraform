data "aws_ec2_managed_prefix_list" s3_gateway_prefix {
  id = aws_vpc_endpoint.s3_gateway.prefix_list_id
}


# Create a VPC
resource "aws_vpc" "openshift" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
      "purpose": "openshift"
      "Name": "openshift-private"
  }
}

resource "aws_route53_zone" "private_hosted_zone" {
  name = "private-zone.skylab.com"

  vpc {
    vpc_id = aws_vpc.openshift.id
  }
}

 resource "aws_ecr_repository" "registry" {
  name                 = "registry"
  image_tag_mutability = "MUTABLE"
  

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.openshift.id

  tags = {
    Name = format("%s-igw", aws_vpc.openshift.tags["Name"])
  }
}