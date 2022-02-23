Subnets:
    3 Private subnets in 3 different AZ. Each subnets have the same ACLS

Route Tables
    private subnets. Route table to route locally within the VPC
    Squid Subnets 

security groups
   master group
   worker group
   Note: most of the communication is only allowed as long as the source is either one of these security group. Exceptions to these rules are
       * icmp can come from anywhere within the VPC
       * ssh can come from anywhere within the VPC??? maybe we dont need this

Instance IAM roles
    Master-role
        load balancer IAM roles are needed because the cloud controller needs to create a load balancer and mantain the targets
        for the openshift router pods which are exposed via a "loadbalancer" kubernetes service which in turns creates an ELB
    Worker-role


external-api network load balancer
    Description: This is used for communication to the api server from outside the cluster
    Listners:
        default forward listener to port 6443 for target group
    target group:
        group for port 6443. actual targets will be added by lambda function

interal-api network load balancer
    Description: this is used for communication inside of the cluster
    Listeners:
        6443: for api communication
        22623: for etcd communication. Example, needed for bootstrapping
    target groups
        6443: 
    
        
Route 53:
    A record: Creates a record for the ext api endpoint on the partent hostze zone

    Hosted zone:
        Description: Cluster needs its own private hosted zone inside the parent hosted zone
