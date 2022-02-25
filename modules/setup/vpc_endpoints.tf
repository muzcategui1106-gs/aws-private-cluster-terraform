resource "aws_vpc_endpoint" "ec2_private_subnets" {
  vpc_id       = aws_vpc.openshift.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_ids = [for s in aws_subnet.vpc_endpoints_subnet : "${s.id}"]
  tags = {
      "purpose": "openshift"
      "Name": "ec2-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = aws_vpc.openshift.id
  service_name = "com.amazonaws.us-east-1.s3"
  tags = {
      "purpose": "openshift"
      "Name": "s3-gateway-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "elasticloadbalancing_private_subnets" {
  vpc_id       = aws_vpc.openshift.id
  service_name = "com.amazonaws.us-east-1.elasticloadbalancing"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_ids = [for s in aws_subnet.vpc_endpoints_subnet : "${s.id}"]
  tags = {
      "purpose": "openshift"
      "Name": "elasticloadbalancing-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "sts_private_subnets" {
  vpc_id       = aws_vpc.openshift.id
  service_name = "com.amazonaws.us-east-1.sts"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_ids = [for s in aws_subnet.vpc_endpoints_subnet : "${s.id}"]
  tags = {
      "purpose": "openshift"
      "Name": "sts-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_docker_endpoint_private_subnets_and_bastion_subnet" {
  vpc_id       = aws_vpc.openshift.id
  service_name = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_ids = concat([for s in aws_subnet.vpc_endpoints_subnet : "${s.id}"])
  tags = {
      "purpose": "openshift"
      "Name": "ecr-docker-endpoint-vpc-endpoint"
  }
}

resource "aws_vpc_endpoint" "ecr_api_endpoint_private_subnets_and_bastion_subnet" {
  vpc_id       = aws_vpc.openshift.id
  service_name = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
  security_group_ids = [aws_security_group.allow_all_traffic.id]
  subnet_ids = concat([for s in aws_subnet.vpc_endpoints_subnet : "${s.id}"])
  tags = {
      "purpose": "openshift"
      "Name": "ecr-api-endpoint-vpc-endpoint"
  }
}


resource "aws_security_group" "allow_all_traffic" {
  name        = "allow_all"
  description = "Allow  all traffic"
  vpc_id      = aws_vpc.openshift.id

  ingress {
    description      = "all all from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = concat([aws_vpc.openshift.cidr_block], [for p in data.aws_ec2_managed_prefix_list.s3_gateway_prefix.entries : "${p.cidr}"])
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = concat([aws_vpc.openshift.cidr_block], [for p in data.aws_ec2_managed_prefix_list.s3_gateway_prefix.entries : "${p.cidr}"])
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      "purpose": "openshift"
      "Name": "allow_all"
  }
}