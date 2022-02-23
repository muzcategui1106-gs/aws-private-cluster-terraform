resource "aws_security_group" "worker" {
  vpc_id      = data.aws_vpc.openshift.id
  description = "security group for worker"
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  security_group_id = aws_security_group.worker.id
  description       = "egress to any port within the VPC and S3"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = concat([data.aws_vpc.openshift.cidr_block], local.s3_prefixes)
}

resource "aws_security_group_rule" "worker_ingress_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "require icm communication"

  protocol    = "icmp"
  cidr_blocks = [data.aws_vpc.openshift.cidr_block]
  from_port   = -1
  to_port     = -1
}

resource "aws_security_group_rule" "worker_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "ssh traffic"

  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = [data.aws_vpc.openshift.cidr_block] # TODO figure out how to reduce this further
}


resource "aws_security_group_rule" "worker_ingress_vxlan" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "vxlan traffic from worker"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_vxlan_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "vxlan traffic from master"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}

resource "aws_security_group_rule" "worker_ingress_geneve" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "vxlan geneve from worker"

  protocol  = "udp"
  from_port = 6081
  to_port   = 6081
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_ike" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "ipsec ike from worker"

  protocol  = "udp"
  from_port = 500
  to_port   = 500
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_ike_nat_t" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "ipsect ike nat from worker"

  protocol  = "udp"
  from_port = 4500
  to_port   = 4500
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_esp" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "ipsec from worker"

  protocol  = 50
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_geneve_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "geneve from master"

  protocol  = "udp"
  from_port = 6081
  to_port   = 6081
}

resource "aws_security_group_rule" "worker_ingress_ike_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "ipsec ike from master"

  protocol  = "udp"
  from_port = 500
  to_port   = 500
}

resource "aws_security_group_rule" "worker_ingress_nat_t_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "nat from master"

  protocol  = "udp"
  from_port = 4500
  to_port   = 4500
}

resource "aws_security_group_rule" "worker_ingress_esp_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "ipsec from master"

  protocol  = 50
  from_port = 0
  to_port   = 0
}

resource "aws_security_group_rule" "worker_ingress_internal" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "internal communication from workers"

  protocol  = "tcp"
  from_port = 9000
  to_port   = 9999
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_internal_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "internal communication from masters"

  protocol  = "tcp"
  from_port = 9000
  to_port   = 9999
}

resource "aws_security_group_rule" "worker_ingress_internal_udp" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "internal communication from workers"

  protocol  = "udp"
  from_port = 9000
  to_port   = 9999
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_internal_from_master_udp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "internal communication from masters"

  protocol  = "udp"
  from_port = 9000
  to_port   = 9999
}

resource "aws_security_group_rule" "worker_ingress_kubelet_insecure" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "kubelet insecure from worker"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_kubelet_insecure_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "kubelet insecure from master"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
}

resource "aws_security_group_rule" "worker_ingress_services_tcp" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "ingress services from worker"

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_services_tcp_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              =  "ingress services from master"
  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
}

resource "aws_security_group_rule" "worker_ingress_services_udp" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id
  description       = "ingress services from worker"

  protocol  = "udp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "worker_ingress_services_udp_from_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.master.id
  description              = "ingress services from master"

  protocol  = "udp"
  from_port = 30000
  to_port   = 32767
}

resource "aws_iam_role" "worker-role" {
  name = "worker-role"
  assume_role_policy = data.aws_iam_policy_document.assume-instance-role.json
}

resource "aws_iam_policy" "worker-policy" {
  name = "worker-policy"
  description = "polciy for worker instances"
  policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:DescribeInstances",
              "ec2:DescribeRegions"
            ],
            "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "worker-instance" {
  role = aws_iam_role.worker-role.id
  policy_arn = aws_iam_policy.worker-policy.arn
}

resource "aws_iam_instance_profile" "worker" {
  name = "worker_profile"
  role = aws_iam_role.worker-role.name
}