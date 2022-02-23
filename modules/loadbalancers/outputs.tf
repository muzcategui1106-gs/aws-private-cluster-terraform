output "external_api_target_group_arn" {
    description = "the trget group arn for the external api group"
    value = "${aws_lb_target_group.external-api.arn}"
}

output "internal_api_target_group_arn" {
    description = "the trget group arn for the internal api group"
    value = "${aws_lb_target_group.internal-api.arn}"
}

output "internal_api_mco_target_group_arn" {
    description = "the trget group arn for the etcd group"
    value = "${aws_lb_target_group.internal-api-etcd.arn}"
}