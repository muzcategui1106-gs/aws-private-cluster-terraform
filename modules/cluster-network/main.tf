data "aws_vpc" "openshift" {
  id = var.vpc_id
}

data "aws_vpc_endpoint" "s3" {
  id = "${var.s3_gateway_endpoint_id}"
}

data "aws_ec2_managed_prefix_list" s3_gateway_prefix {
  id = data.aws_vpc_endpoint.s3.prefix_list_id
}