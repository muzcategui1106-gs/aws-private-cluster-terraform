resource "aws_security_group" "master" {
  vpc_id      = data.aws_vpc.openshift.id
  description = "master sg"
}

resource "aws_security_group_rule" "master_mcs" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "machine config operator port needed for bootstrapping master and worker nodes"

  protocol    = "tcp"
  from_port   = 22623
  to_port     = 22623
  cidr_blocks = [for s in aws_subnet.private_subnet : s.cidr_block]
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  security_group_id = aws_security_group.master.id
  description       = "egress to any port within the VPC and S3"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = concat([data.aws_vpc.openshift.cidr_block], local.s3_prefixes)
}

resource "aws_security_group_rule" "master_ingress_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "icmp required traffic"

  protocol    = "icmp"
  cidr_blocks = [data.aws_vpc.openshift.cidr_block]
  from_port   = -1
  to_port     = -1
}

resource "aws_security_group_rule" "master_ingress_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "ssh traffic"

  protocol    = "tcp"
  cidr_blocks = [data.aws_vpc.openshift.cidr_block] # this could be blocked to probably the bastion subnet
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "master_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "communication with the api server from within any of the subnets of the cluster" 

  protocol    = "tcp"
  cidr_blocks = [for s in aws_subnet.private_subnet : s.cidr_block] # this could be further modify to be only from the worker and master SG and whatever we do for the ingress so that kubectl works
  from_port   = 6443
  to_port     = 6443
}

resource "aws_security_group_rule" "master_ingress_vxlan" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "vxlan from master"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
  self      = true
}

resource "aws_security_group_rule" "master_ingress_vxlan_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "vxlan from worker"

  protocol  = "udp"
  from_port = 4789
  to_port   = 4789
}

resource "aws_security_group_rule" "master_ingress_geneve" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "vxlan geneve from master"

  protocol  = "udp"
  from_port = 6081
  to_port   = 6081
  self      = true
}

resource "aws_security_group_rule" "master_ingress_ike" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "ipsec ike from master"

  protocol  = "udp"
  from_port = 500
  to_port   = 500
  self      = true
}

resource "aws_security_group_rule" "master_ingress_ike_nat_t" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "ipsect ike nat from master"

  protocol  = "udp"
  from_port = 4500
  to_port   = 4500
  self      = true
}

resource "aws_security_group_rule" "master_ingress_esp" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "ipsec from master"

  protocol  = 50
  from_port = 0
  to_port   = 0
  self      = true
}

resource "aws_security_group_rule" "master_ingress_geneve_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "vxlan geneve from worker"

  protocol  = "udp"
  from_port = 6081
  to_port   = 6081
}

resource "aws_security_group_rule" "master_ingress_ike_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "ipsec ike from worker"

  protocol  = "udp"
  from_port = 500
  to_port   = 500
}

resource "aws_security_group_rule" "master_ingress_ike_nat_t_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "ipsect ike nat from worker"

  protocol  = "udp"
  from_port = 4500
  to_port   = 4500
}

resource "aws_security_group_rule" "master_ingress_esp_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "ipsec esp from worker"

  protocol  = 50
  from_port = 0
  to_port   = 0
}

resource "aws_security_group_rule" "master_ingress_ovndb" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "ovndb traffic from master"

  protocol  = "tcp"
  from_port = 6641
  to_port   = 6642
  self      = true
}

resource "aws_security_group_rule" "master_ingress_ovndb_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "ovndb from worker"

  protocol  = "tcp"
  from_port = 6641
  to_port   = 6642
}

resource "aws_security_group_rule" "master_ingress_internal" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "communication intra cluster from master"

  protocol  = "tcp"
  from_port = 9000
  to_port   = 9999
  self      = true
}

resource "aws_security_group_rule" "master_ingress_internal_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "communication intra cluster from worker"

  protocol  = "tcp"
  from_port = 9000
  to_port   = 9999
}

resource "aws_security_group_rule" "master_ingress_internal_udp" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "communication intra cluster from master"

  protocol  = "udp"
  from_port = 9000
  to_port   = 9999
  self      = true
}

resource "aws_security_group_rule" "master_ingress_internal_from_worker_udp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "communication intra cluster from worker"

  protocol  = "udp"
  from_port = 9000
  to_port   = 9999
}

resource "aws_security_group_rule" "master_ingress_kube_scheduler" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "kube-scheduler traffic from master"

  protocol  = "tcp"
  from_port = 10259
  to_port   = 10259
  self      = true
}

resource "aws_security_group_rule" "master_ingress_kube_scheduler_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "kube-scheduler traffic from worker"

  protocol  = "tcp"
  from_port = 10259
  to_port   = 10259
}

resource "aws_security_group_rule" "master_ingress_kube_controller_manager" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "kube-controller-manager traffic from master"

  protocol  = "tcp"
  from_port = 10257
  to_port   = 10257
  self      = true
}

resource "aws_security_group_rule" "master_ingress_kube_controller_manager_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "kube-controller-manager traffic from worker"

  protocol  = "tcp"
  from_port = 10257
  to_port   = 10257
}

resource "aws_security_group_rule" "master_ingress_kubelet_secure" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "kubelet traffic from master"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
  self      = true
}

resource "aws_security_group_rule" "master_ingress_kubelet_secure_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "kubelet traffic from worker"

  protocol  = "tcp"
  from_port = 10250
  to_port   = 10250
}

resource "aws_security_group_rule" "master_ingress_etcd" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "etcd communication from master"

  protocol  = "tcp"
  from_port = 2379
  to_port   = 2380
  self      = true
}

resource "aws_security_group_rule" "master_ingress_services_tcp" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       = "ingress services from master"

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "master_ingress_services_tcp_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "ingress services from worker"

  protocol  = "tcp"
  from_port = 30000
  to_port   = 32767
}

resource "aws_security_group_rule" "master_ingress_services_udp" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id
  description       =  "ingress services from master"

  protocol  = "udp"
  from_port = 30000
  to_port   = 32767
  self      = true
}

resource "aws_security_group_rule" "master_ingress_services_udp_from_worker" {
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  source_security_group_id = aws_security_group.worker.id
  description              = "ingress services from worker"

  protocol  = "udp"
  from_port = 30000
  to_port   = 32767
}

data "aws_iam_policy_document" "assume-instance-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "master-role" {
  name = "master-role"
  assume_role_policy = data.aws_iam_policy_document.assume-instance-role.json
}

resource "aws_iam_policy" "master-policy" {
  name = "master-policy"
  description = "polciy for master instances"
  policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ec2:AttachVolume",
              "ec2:AuthorizeSecurityGroupIngress",
              "ec2:CreateSecurityGroup",
              "ec2:CreateTags",
              "ec2:CreateVolume",
              "ec2:DeleteSecurityGroup",
              "ec2:DeleteVolume",
              "ec2:Describe*",
              "ec2:DetachVolume",
              "ec2:ModifyInstanceAttribute",
              "ec2:ModifyVolume",
              "ec2:RevokeSecurityGroupIngress",
              "elasticloadbalancing:AddTags",
              "elasticloadbalancing:AttachLoadBalancerToSubnets",
              "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
              "elasticloadbalancing:CreateListener",
              "elasticloadbalancing:CreateLoadBalancer",
              "elasticloadbalancing:CreateLoadBalancerPolicy",
              "elasticloadbalancing:CreateLoadBalancerListeners",
              "elasticloadbalancing:CreateTargetGroup",
              "elasticloadbalancing:ConfigureHealthCheck",
              "elasticloadbalancing:DeleteListener",
              "elasticloadbalancing:DeleteLoadBalancer",
              "elasticloadbalancing:DeleteLoadBalancerListeners",
              "elasticloadbalancing:DeleteTargetGroup",
              "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
              "elasticloadbalancing:DeregisterTargets",
              "elasticloadbalancing:Describe*",
              "elasticloadbalancing:DetachLoadBalancerFromSubnets",
              "elasticloadbalancing:ModifyListener",
              "elasticloadbalancing:ModifyLoadBalancerAttributes",
              "elasticloadbalancing:ModifyTargetGroup",
              "elasticloadbalancing:ModifyTargetGroupAttributes",
              "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
              "elasticloadbalancing:RegisterTargets",
              "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
              "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
              "kms:DescribeKey"
            ],
            "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "master-instance" {
  role = aws_iam_role.master-role.id
  policy_arn = aws_iam_policy.master-policy.arn
}

resource "aws_iam_instance_profile" "master" {
  name = "master_profile"
  role = aws_iam_role.master-role.name
}