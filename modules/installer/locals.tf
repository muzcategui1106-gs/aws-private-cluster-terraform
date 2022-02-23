locals {
    bootstrap_location = "s3://${aws_s3_bucket.installer-resources.bucket}/bootstrap.ign"
    master_ignition = data.aws_s3_bucket_object.master_ign.body
    worker_ignition = data.aws_s3_bucket_object.worker_ign.body
    infra_name = jsondecode(data.aws_s3_bucket_object.metadata.body)["infraID"]
}