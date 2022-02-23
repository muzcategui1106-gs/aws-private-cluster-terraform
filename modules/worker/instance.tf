resource "aws_instance" "worker" {
  count = length("${var.subnet_ids}")
  # retrieved using ./openshift-install coreos print-stream-json | jq -r '.architectures.x86_64.images.aws.regions["us-west-1"].image'
  ami           = "ami-0a57c1b4939e5ef5b" # note this is specific to us-east-1 and it was retrieved using
  instance_type = "c5.2xlarge"
  iam_instance_profile = "${var.worker_instance_profile_name}"

  tags = {
    Name = "worker-${count.index}"
    "kubernetes.io/cluster/${var.infra_name}": "shared"
  }

  subnet_id = "${var.subnet_ids[count.index]}"
  security_groups = ["${var.worker_security_group_id}"]
  key_name = "ocp-bastio-host-key"
  user_data = <<EOF
${var.worker_ignition}
  EOF
}