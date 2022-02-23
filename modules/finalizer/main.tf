data "aws_route53_zone" "hosted_zone" {
  zone_id = "${var.hosted_zone_id}"
}

data "aws_elb" "apps" {
    name = "a09e3a807a0594fef8792e3297c33b67"
}

resource "aws_route53_record" "apps-record" {
 zone_id = data.aws_route53_zone.hosted_zone.zone_id
 name = "*.apps.private-cluster.private-zone.skylab.com"
 type = "A"
 alias {
    name                   = data.aws_elb.apps.dns_name
    zone_id                = data.aws_elb.apps.zone_id
    evaluate_target_health = true
  }
}