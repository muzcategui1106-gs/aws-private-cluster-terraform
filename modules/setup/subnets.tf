data "aws_availability_zones" "available" {}

resource "aws_subnet" "vpc_endpoints_subnet" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.openshift.id}"
  cidr_block = "10.0.254.${32*count.index}/27"
  availability_zone= "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false
  tags = {
    Name = "vpc-endpoint-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

