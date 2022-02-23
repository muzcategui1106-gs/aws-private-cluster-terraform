############ External Load Balancer ################
resource "aws_lb" "external-api" {
  name               = "${var.infra_name}-ext"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in var.subnet_ids : subnet]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "external-api" {
  load_balancer_arn = aws_lb.external-api.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-api.arn
  }
}

resource "aws_lb_target_group" "external-api" {
  name     = "external-api"
  port     = 6443
  protocol = "TCP"
  vpc_id   = data.aws_vpc.openshift.id
  health_check  {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    path = "/readyz"
    port = 6443
    protocol = "HTTPS"
  }
  target_type = "ip"
}
#################################

################# Interal load balancer ############################
resource "aws_lb" "internal-api" {
  name               = "${var.infra_name}-int"
  internal           = true
  load_balancer_type = "network"
  subnets            = [for subnet in var.subnet_ids : subnet]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "internal-api" {
  load_balancer_arn = aws_lb.internal-api.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-api.arn
  }
}

resource "aws_lb_listener" "internal-api-etcd" {
  load_balancer_arn = aws_lb.internal-api.arn
  port              = "22623"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal-api-etcd.arn
  }
}

resource "aws_lb_target_group" "internal-api" {
  name     = "internal-api"
  port     = 6443
  protocol = "TCP"
  vpc_id   = data.aws_vpc.openshift.id
  health_check  {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    path = "/readyz"
    port = 6443
    protocol = "HTTPS"
  }
  target_type = "ip"
}

# TODO this is not etcd this is for the mco API
resource "aws_lb_target_group" "internal-api-etcd" {
  name     = "internal-api-etcd"
  port     = 22623
  protocol = "TCP"
  vpc_id   = data.aws_vpc.openshift.id
  health_check  {
    enabled = true
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    path = "/healthz"
    port = 22623
    protocol = "HTTPS"
  }
  target_type = "ip"
}
#############################################

############# cluster route 53 records ##############
resource "aws_route53_record" "external-api-record" {
  zone_id = "${var.hosted_zone_id}"
  name    = "api.private-cluster.private-zone.skylab.com"
  type    = "A"
  alias {
    name = aws_lb.internal-api.dns_name
    zone_id = aws_lb.external-api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "internal-api-record" {
  zone_id = "${var.hosted_zone_id}"
  name    = "api-int.private-cluster.private-zone.skylab.com"
  type    = "A"
  alias {
    name = aws_lb.internal-api.dns_name
    zone_id = aws_lb.internal-api.zone_id
    evaluate_target_health = true
  }
}
#################################################