Resources needed

VPC: Need a VPC. VPC must have enable DNS support
     Enable DNS hostnames. You must enable the enableDnsSupport and enableDnsHostnames attributes in your VPC, so that the cluster can use the Route 53 zones that are attached to the VPC to resolve cluster’s internal DNS records. See DNS Support in Your VPC in the AWS documentation.

Route 53 private hostez zone

VPC endpoints:
    interface endpoints 
        ec2
        elasticloadbalancing
    gateway endpoints:
        s3 used to provide native s3 connectivity to clusters without internet
        look into enabling gateway policy to specific buckets
    security groups for these vpc endpoints to allow all incoming traffic from within the VPC

Internet Gateway: This is only for POC at home. Not for POC/preprod/production setup on real AWS accounts. I just need connectivity to get to the internet. In reality this will be done via Iboss Proxy




