data "aws_iam_policy_document" "assume-instance-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "bootstrap" {
  name = "bootstrap-role"
  assume_role_policy = data.aws_iam_policy_document.assume-instance-role.json
}

resource "aws_iam_policy" "bootstrap" {
  name = "bootstrap-policy"
  description = "polciy for bootstrap instances"
  policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "s3:GetObject",
              "ec2:Describe*",
              "ec2:AttachVolume",
              "ec2:DetachVolume"
            ],
            "Resource": "*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bootstrap" {
  role = aws_iam_role.bootstrap.id
  policy_arn = aws_iam_policy.bootstrap.arn
}

resource "aws_iam_instance_profile" "bootstrap" {
  name = "bootstrap_profle"
  role = aws_iam_role.bootstrap.name
}

resource "aws_security_group" "bootstrap" {
  vpc_id      = data.aws_vpc.openshift.id
  description = "bootstrap security group"

  ingress {
    description      = "port for something"
    from_port        = 19531
    to_port          = 19531
    protocol         = "tcp"
    cidr_blocks      = [data.aws_vpc.openshift.cidr_block]
  }

  tags = {
    Name = "bootstrap security group"
  }
}

resource "aws_instance" "bootstrap" {
  # retrieved using ./openshift-install coreos print-stream-json | jq -r '.architectures.x86_64.images.aws.regions["us-west-1"].image'
  ami           = "ami-0a57c1b4939e5ef5b" # note this is specific to us-east-1 and it was retrieved using
  instance_type = "c5.2xlarge"
  iam_instance_profile = aws_iam_instance_profile.bootstrap.name
  vpc_security_group_ids = []

  tags = {
    Name = "bootstrap"
  }

  subnet_id = "${var.boostrap_subnet_id}"
  security_groups = [aws_security_group.bootstrap.id, "${var.master_security_group_id}"]
  key_name = "ocp-bastio-host-key"
  user_data = <<EOF
{"ignition":{"config":{"replace":{"source":"${var.bootstrap_location}"}},"version":"3.1.0"}}
  EOF
}

resource "aws_lb_target_group_attachment" "external-api" {
  target_group_arn = var.external_api_target_group_arn
  target_id        = aws_instance.bootstrap.private_ip
}

resource "aws_lb_target_group_attachment" "internal-api" {
  target_group_arn = var.internal_api_target_group_arn
  target_id        = aws_instance.bootstrap.private_ip
}

resource "aws_lb_target_group_attachment" "internal-mco" {
  target_group_arn = var.internal_api_mco_target_group_arn
  target_id        = aws_instance.bootstrap.private_ip
}