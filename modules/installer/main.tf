data "aws_vpc" "openshift" {
  id = var.vpc_id
}

data "aws_s3_bucket_object" "metadata" {
  bucket = "${aws_s3_bucket.installer-resources.bucket}"
  key = "metadata.json"
  depends_on = [data.aws_lambda_invocation.generate-ignition-files]
}

data "aws_s3_bucket_object" "master_ign" {
  bucket = "${aws_s3_bucket.installer-resources.bucket}"
  key = "master.ign"
  depends_on = [data.aws_lambda_invocation.generate-ignition-files]
}

data "aws_s3_bucket_object" "worker_ign" {
  bucket = "${aws_s3_bucket.installer-resources.bucket}"
  key = "worker.ign"
  depends_on = [data.aws_lambda_invocation.generate-ignition-files]
}