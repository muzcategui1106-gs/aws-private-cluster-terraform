terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  profile = "default"
}

module "setup" {
  source = "./modules/setup"

  cidr_block = "10.0.0.0/16"
}

module "bastion" {
  source = "./modules/bastion"

  vpc_id = "${module.setup.vpc_id}"
}

module "squid" {
  source = "./modules/squid"

  vpc_id = "${module.setup.vpc_id}"
  cluster_name = "private-cluster"
  subnets = {
    "us-east-1a": "10.0.4.0/24",
    "us-east-1b": "10.0.5.0/24",
    "us-east-1c": "10.0.6.0/24",
  }
}

module cluster-network {
    source = "./modules/cluster-network"

    vpc_id = "${module.setup.vpc_id}"
    s3_gateway_endpoint_id = "${module.setup.s3_gateway_vpc_endpoint_id}"
    cluster_name = "private-cluster"
    subnets = {
      "us-east-1a": "10.0.1.0/24",
      "us-east-1b": "10.0.2.0/24",
      "us-east-1c": "10.0.3.0/24",
    }
}

module installer {
  source = "./modules/installer"

  vpc_id = "${module.setup.vpc_id}"
  cluster_name = "private-cluster"
  subnet_ids = split(",", "${module.cluster-network.subnets}")
}

module loadbalancers {
  source = "./modules/loadbalancers"

  vpc_id = "${module.setup.vpc_id}"
  infra_name = "${module.installer.infra_name}"
  subnet_ids = split(",", "${module.cluster-network.subnets}")
  hosted_zone_id = "${module.setup.hosted_zone_id}"
}

module bootstrap {
  source = "./modules/bootstrap"

  vpc_id = "${module.setup.vpc_id}"
  boostrap_subnet_id = split(",", "${module.cluster-network.subnets}")[0]
  bootstrap_location = "${module.installer.bootstrap_location}"
  master_security_group_id = "${module.cluster-network.master_security_group_id}"
  external_api_target_group_arn = "${module.loadbalancers.external_api_target_group_arn}"
  internal_api_target_group_arn = "${module.loadbalancers.internal_api_target_group_arn}"
  internal_api_mco_target_group_arn = "${module.loadbalancers.internal_api_mco_target_group_arn}"
}

module master {
  source = "./modules/master"

  subnet_ids = split(",", "${module.cluster-network.subnets}")
  master_security_group_id = "${module.cluster-network.master_security_group_id}"
  external_api_target_group_arn = "${module.loadbalancers.external_api_target_group_arn}"
  internal_api_target_group_arn = "${module.loadbalancers.internal_api_target_group_arn}"
  internal_api_mco_target_group_arn = "${module.loadbalancers.internal_api_mco_target_group_arn}"
  master_instance_profile_name = "${module.cluster-network.master_instance_profile_name}"
  master_ignition = "${module.installer.master_ignition}"
  infra_name = "${module.installer.infra_name}"
}

module worker {
  source = "./modules/worker"

  subnet_ids = split(",", "${module.cluster-network.subnets}")
  worker_security_group_id = "${module.cluster-network.worker_security_group_id}"
  worker_instance_profile_name = "${module.cluster-network.worker_instance_profile_name}"
  worker_ignition = "${module.installer.worker_ignition}"
  infra_name = "${module.installer.infra_name}"
}

module finalizer {
  source = "./modules/finalizer"

  hosted_zone_id = "${module.setup.hosted_zone_id}"
  infra_name = "${module.installer.infra_name}"
}