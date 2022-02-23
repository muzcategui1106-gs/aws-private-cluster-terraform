output "vpc_id" {
  description = "the id of the vpc"
  value       = aws_vpc.openshift.id
}

output "hosted_zone_id" {
  description = "the id of the hosted zone onto which deploy the cluster"
  value = aws_route53_zone.private_hosted_zone.id
}

output s3_gateway_vpc_endpoint_id {
  description = "s3 vpc gateway endpoint id"
  value = aws_vpc_endpoint.s3_gateway.id
}