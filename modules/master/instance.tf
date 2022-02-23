resource "aws_instance" "master" {
  count = length("${var.subnet_ids}")
  # retrieved using ./openshift-install coreos print-stream-json | jq -r '.architectures.x86_64.images.aws.regions["us-west-1"].image'
  ami           = "ami-0a57c1b4939e5ef5b" # note this is specific to us-east-1 and it was retrieved using
  instance_type = "c5.2xlarge"
  iam_instance_profile = "${var.master_instance_profile_name}"

  tags = {
    Name = "control-plane-${count.index}"
    "kubernetes.io/cluster/${var.infra_name}": "shared"
  }

  subnet_id = "${var.subnet_ids[count.index]}"
  security_groups = ["${var.master_security_group_id}"]
  key_name = "ocp-bastio-host-key"
  user_data = <<EOF
${var.master_ignition}
  EOF
}

resource "aws_lb_target_group_attachment" "master-external-api" {
  count = length("${var.subnet_ids}")
  target_group_arn = var.external_api_target_group_arn
  target_id        = aws_instance.master[count.index].private_ip
}

resource "aws_lb_target_group_attachment" "master-internal-api" {
  count = length("${var.subnet_ids}")
  target_group_arn = var.internal_api_target_group_arn
  target_id        = aws_instance.master[count.index].private_ip
}

resource "aws_lb_target_group_attachment" "master-internal-mco" {
  count = length("${var.subnet_ids}")
  target_group_arn = var.internal_api_mco_target_group_arn
  target_id        = aws_instance.master[count.index].private_ip
}