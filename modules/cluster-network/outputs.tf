output "subnets" {
    description = "list of subnets comma separated for this cluster"
    value = join(",", [for subnet in aws_subnet.private_subnet : subnet.id])
}

output "master_security_group_id" {
    description = "the id of the security group for the masters"
    value = aws_security_group.master.id
}


output "worker_security_group_id" {
    description = "the id of the security group for the workers"
    value = aws_security_group.worker.id
}

output "master_instance_profile_name" {
    description = "name of the master instance profile"
    value = aws_iam_instance_profile.master.name
}

output "worker_instance_profile_name" {
    description = "name of the worker instance profile"
    value = aws_iam_instance_profile.worker.name
}