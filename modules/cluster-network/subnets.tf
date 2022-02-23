resource "aws_subnet" "private_subnet" {
  for_each = {
      for sub in local.private_subnets : sub.name => sub
  }

  availability_zone = "${each.value.availability_zone}"
  cidr_block = "${each.value.cidr}"
  vpc_id = "${data.aws_vpc.openshift.id}"
  tags = {
      cluster = "${each.value.cluster_name}",
      Name = format("%s-%s-private-subnet", "${each.value.cluster_name}", "${each.value.availability_zone}")
  }
}

resource "aws_route_table" "private_subnet_route_table" {
  for_each = aws_subnet.private_subnet
  vpc_id = data.aws_vpc.openshift.id

  tags = {
    Name = format("rt-%s",  each.value.tags["Name"]),
    cluster =  each.value.tags["cluster"]
    subnet_id = "${each.value.id}"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_gateway_routes" {
  for_each = aws_route_table.private_subnet_route_table
  route_table_id  = each.value.id
  vpc_endpoint_id = "${data.aws_vpc_endpoint.s3.id}"
}

resource "aws_route_table_association" "private_subnet_rt_association" {
  for_each =  aws_route_table.private_subnet_route_table
  subnet_id      = "${each.value.tags["subnet_id"]}"
  route_table_id = each.value.id
}

resource "aws_network_acl" "openshift" {
  vpc_id = data.aws_vpc.openshift.id
  subnet_ids = [for s in aws_subnet.private_subnet : "${s.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 101
    action     = "allow"
    cidr_block = data.aws_vpc.openshift.cidr_block
    from_port = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 102
    action     = "allow"
    cidr_block = data.aws_vpc.openshift.cidr_block
    from_port = 1024
    to_port    = 65535
  }


  ingress {
    protocol   = "udp"
    rule_no    = 103
    action     = "allow"
    cidr_block = data.aws_vpc.openshift.cidr_block
    from_port = 1024
    to_port    = 65535
  }

  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 0
    to_port    = 0
  }

  tags = {
      "purpose": "openshift-subnets"
  }
}

resource "aws_network_acl_rule" "s3_ingress_tcp" {
  count = length(local.s3_prefixes)
  rule_number = 300 + count.index
  network_acl_id = aws_network_acl.openshift.id
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = local.s3_prefixes[count.index]
  from_port = 1024
  to_port    = 65535
}

resource "aws_network_acl_rule" "s3_ingress_udp" {
  count = length(local.s3_prefixes)
  rule_number = 320 + count.index
  network_acl_id = aws_network_acl.openshift.id
  egress         = false
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = local.s3_prefixes[count.index]
  from_port = 1024
  to_port    = 65535
}
