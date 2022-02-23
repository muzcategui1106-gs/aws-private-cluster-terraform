resource "aws_subnet" "public_squid_subnet" {
  for_each = {
      for sub in local.public_squid_subnets : sub.name => sub
  }

  availability_zone = "${each.value.availability_zone}"
  cidr_block = "${each.value.cidr}"
  vpc_id = "${data.aws_vpc.openshift.id}"
  tags = {
      cluster = "${each.value.cluster_name}",
      Name = format("%s-%s-public-squid-subnet", "${each.value.cluster_name}", "${each.value.availability_zone}")
  }
}