resource "aws_route_table" "public_squid_subnet_route_table" {
  for_each = aws_subnet.public_squid_subnet
  vpc_id = data.aws_vpc.openshift.id

  route {
    cidr_block        = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name = format("rt-%s",  each.value.tags["Name"]),
    cluster =  each.value.tags["cluster"]
    subnet_id = "${each.value.id}"
  }
}

resource "aws_route_table_association" "public_squid_subnet_rt_association" {
  for_each =  aws_route_table.public_squid_subnet_route_table
  subnet_id      = "${each.value.tags["subnet_id"]}"
  route_table_id = each.value.id
}