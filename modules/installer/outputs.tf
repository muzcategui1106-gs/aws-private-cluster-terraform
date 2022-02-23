output bootstrap_location {
    description = "the name of the bucket containing bootstrap resources"
    value = "${local.bootstrap_location}"
}

output infra_name {
    description = "infrastructure name"
    value = "${local.infra_name}"
}

output master_ignition {
    description = "master ignition config"
    value = "${local.master_ignition}"
}

output worker_ignition{
    description = "worker_ignition"
    value = "${local.worker_ignition}"
}