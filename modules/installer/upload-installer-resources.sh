tmp_dir="$(mktemp -d -t  installer-resources-XXXXX)"
echo "setting temp dir to $tmp_dir"

wget -O  /Users/migueluzcategui/dev/openshift-aws-terraform/aws-private-cluster-terraform/modules/installer/openshift-install.tar.gz https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.9.19/openshift-install-linux.tar.gz

#### for the purposes of this POC we are going to cheat a little bit. Since I have I am going to assume that I could run the 
### following commands succesfully

# oc adm release extract --credentials-requests --cloud=aws --to creds quay.io/openshift-release-dev/ocp-release@sha256:fd96300600f9585e5847f5855ca14e2b3cafbce12aefe3b3f52c5da10c4476eb
# ccoctl aws create-all --name=<name> --region=<aws_region> --credentials-requests-dir=<path_to_directory_with_list_of_credentials_requests>/credrequests


# for now what I did was to generate the files from the oc command and upload them to the s3 bucket
# then I use ccoctl in the lambda function itself to create the files

# there is no reason why these steps cannot be done outside of aws altogether


