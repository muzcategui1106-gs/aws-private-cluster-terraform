Instace profile with policy for the bootstrap

Instance profile
    Description: profile with specific role for bootstrap

Instace:
    Description: Instance for the bootstrap with user data pointing to the S3 bucket. The instance needs the ability to talk to the bootstrap bucket. Which means it needs to talk to S3 over the gateway vpc endpoint interface

Lambdas
    Description: Register against the different NLB target groups
        external-api
        internal-api
        etcd

TODO
    Consider somehow adding lambda triggers that register the bootstrap automatically
