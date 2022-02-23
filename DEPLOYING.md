# Overview

this is a step by step guide on how to deploy an openshift cluster

Prerequisites
  * have an ssh key pair in aws (this can be done through terraform)

Run the following commands

```
terraform init
terraform apply --target=module.setup
terraform apply --target=module.cluster-network
terraform apply --target=module.squid # for POC
```

Setup squid proxies
https://aws.amazon.com/blogs/security/how-to-set-up-an-outbound-vpc-proxy-with-domain-whitelisting-and-content-filtering/ 

Modify `modules/installer/install-config-template.yaml` 
    * set the squid proxy
    * cluster-name
    * vpc endpoints
    * other parameters that you wish to tweak. This can be automated

Run the following
```
terraform apply --target=module.installer
```
After this step, ensure there is a bucket created for your cluster with the bootstrap.ign and metadata.json. If there isnt then stop. something went wrong

Run the following
```
terraform apply --target=module.loadbalancers
terraform apply --target=module.bootstrap
terraform apply --target=module.master
```

Verify all API servers are up before continuing

Run the following
```
terraform destroy --target=module.bootstrap
terraform apply --target=module.worker
```

Manually approve CSRs for the workers
Wait for the loadbalancer for the apps service to appear in AWS

Run the following
```
terraform apply --target=module.finalizer
```
