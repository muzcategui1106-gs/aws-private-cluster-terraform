data "aws_vpc" "openshift" {
  id = var.vpc_id
}