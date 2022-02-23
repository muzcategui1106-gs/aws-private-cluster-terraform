resource "aws_s3_bucket" "installer-resources" {
  bucket = "${var.cluster_name}-installer-resources"

  tags = {
    Name = "${var.cluster_name}-installer-resources"
  }
  force_destroy = true
}

resource "null_resource" "get-openshift-installer" {
  provisioner "local-exec" {
    command = "/Users/migueluzcategui/dev/openshift-aws-terraform/aws-private-cluster-terraform/modules/installer/upload-installer-resources.sh"
    interpreter = ["/bin/bash"]
  }
}

resource "aws_s3_bucket_object" "openshift-installer" {
  bucket = aws_s3_bucket.installer-resources.bucket
  key    = "openshift-install.tar.gz"
  source = "/Users/migueluzcategui/dev/openshift-aws-terraform/aws-private-cluster-terraform/modules/installer/openshift-install.tar.gz"

  depends_on = [
    null_resource.get-openshift-installer
  ]
}

resource "aws_s3_bucket_object" "ccoctl" {
  bucket = aws_s3_bucket.installer-resources.bucket
  key    = "ccoctl"
  source = "/Users/migueluzcategui/dev/openshift-aws-terraform/aws-private-cluster-terraform/modules/installer/ccoctl"
}

resource "aws_s3_bucket_object" "install-config-template" {
  bucket = aws_s3_bucket.installer-resources.bucket
  key    = "install-config-template.yaml"
  source = "/Users/migueluzcategui/dev/openshift-aws-terraform/aws-private-cluster-terraform/modules/installer/install-config-template.yaml"
}

resource "aws_s3_bucket_object" "creds" {
for_each = fileset("./modules/installer/creds/", "*")
bucket = aws_s3_bucket.installer-resources.bucket
key = each.value
source = "./modules/installer/creds/${each.value}"
}

