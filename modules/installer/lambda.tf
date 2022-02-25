data "aws_iam_policy_document" "assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "installer-resources-generator" {
  name = "installer-resources-generator"
  assume_role_policy = data.aws_iam_policy_document.assume-role.json
}

resource "aws_iam_policy" "installer-resources-generator" {
  name = "installer-resources-generator"
  description = "register targets against the cluster targets"
  policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["arn:aws:s3:::${aws_s3_bucket.installer-resources.bucket}"]
        },
        {
            "Sid": "AllS3Actions",
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        },
        {
            "Sid": "CreateDeleteNetworkInterfaces",
            "Effect": "Allow",
            "Action": [
              "ec2:DescribeNetworkInterfaces",
              "ec2:CreateNetworkInterface",
              "ec2:DeleteNetworkInterface",
              "ec2:DescribeInstances",
              "ec2:AttachNetworkInterface",
              "ec2:DettachNetworkInterface",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeSubnets",
              "ec2:DescribeVpcs",
              "ec2:DescribeRouteTables",
              "ec2:DescribeInstanceTypes"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ManageIamRoles",
            "Effect": "Allow",
            "Action": [
              "iam:ListOpenIDConnectProviders",
              "iam:GetOpenIDConnectProvider",
              "iam:CreateOpenIDConnectProvider",
              "iam:DeleteOpenIDConnectProvider",
              "iam:TagOpenIDConnectProvider",
              "iam:GetRole",
              "iam:DescribeRole",
              "iam:CreateRole",
              "iam:DeleteRole",
              "iam:TagRole",
              "iam:PutRolePolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "installer-resources-generator" {
  role = aws_iam_role.installer-resources-generator.id
  policy_arn = aws_iam_policy.installer-resources-generator.arn
}

resource "aws_iam_role_policy_attachment" "installer-resources-generator-log-policy" {
  role = aws_iam_role.installer-resources-generator.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



resource "aws_security_group" "installer-resources-generator" {
  name        = "installer-resources-generator"
  description = "Allow  all traffic"
  vpc_id      = data.aws_vpc.openshift.id

  ingress {
    description      = "all all from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [data.aws_vpc.openshift.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      "purpose": "openshift"
      "Name": "allow_all"
  }
}

resource "aws_lambda_function" "installer-resources-generator" {
  filename      = "./modules/installer/generate-install-config.zip"
  function_name = "installer-resources-generator-${var.cluster_name}"
  role          = aws_iam_role.installer-resources-generator.arn
  handler       = "generate-install-config.handler"

  runtime = "python3.7"
  timeout = 240

  memory_size = 2000
  architectures = ["x86_64"]
  

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = [for subnet in var.subnet_ids : subnet]
    security_group_ids = [aws_security_group.installer-resources-generator.id]
  }

  depends_on = [
    aws_security_group.installer-resources-generator,
    aws_iam_role.installer-resources-generator
  ]

    environment {
    variables = {
      NO_PROXY = "vpce.amazonaws.com,public-cluster.uzcatm-skylab.com,s3.amazonaws.com,private-cluster.private-zone.skylab.com,sts.us-east-1.amazonaws.com,ec2.us-east-1.amazonaws.com,elasticloadbalancing.us-east-1.amazonaws.com",
      https_proxy = "http://OutboundProxyLoadBalancer-8372e582731e79fa.elb.us-east-1.amazonaws.com:3128"
    }
  }
}

data "aws_lambda_invocation" "generate-ignition-files" {
  function_name = aws_lambda_function.installer-resources-generator.function_name

  # TODO we need to parametarize the lambda to generate the install-config.yaml and other files in the fly
  input = jsonencode({
    "ResourceProperties": {
    }
     "RequestType": "Create"
     "ResponseURL": ""
     "StackId": ""
  })
}