s3 bucket
    Description: Necessary to hold installer resources. It will end up holding sensitive data for the cluster. Need advise on how to make this secure 

lambda
    Description: Generate installer resources ad setup STS to work with the given OCP cluster
    where it runs:
        Inside the VPC in one of our private subnets. It uses the Same ACLs as the subnet
    Roles
        Expressed in terraform
    Dynamic Setup
        Roles, OpenID connect in IAM (because I am running at home), no need to give perms to lambda to do this at all

Considerations
    Given the lambda function cannot run with admin credentials, the installer makes you use the CCO in manual mode. For this reason I have upted for using the CCO with AWS STS to provide short lived rotating credentials to OCP components with limited scope. This is probably for the better as provides the best security without having to ever expose the admin credentials

Caveats
    For upgrades there might be some manual steps that we need to follow

    The CCOctl does not have to be ran inside the lambda. It just needs a linux box. Since I have a mac at home I had no choice but
    to put it in the lambda. This means that the lambda does not need dynamic permissions to create roles it can all be done with a local executor on the terraform pusher. It does need to be dynamic tho.