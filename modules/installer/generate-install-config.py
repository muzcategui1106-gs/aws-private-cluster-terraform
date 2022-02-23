from cgitb import handler
import boto3
from io import BytesIO
import tarfile
import os
import subprocess
import shutil

def handler(event, context):
    # endpoint_url='https://bucket.vpce-0de980e1739ed97f4-2c36k1t5.s3.us-east-1.vpce.amazonaws.com'
    s3_client = boto3.client(
        service_name='s3'
    )

    # do  a pre-check and do not run again if bootstrap.ign file is in bucket already. this means that a cluster
    # is already installed with an infrastructure name
    bucket = "private-cluster-installer-resources"
    key = "bootstrap.ign"
    has_bootstrap = True
    try:
        s3_client.get_object(Bucket = bucket, Key = key)
    except:
        has_bootstrap = False
    
    if has_bootstrap:
        print("previous installation detected in bucket ... aborting run")
        return
    
    print(os.listdir("."))
    base_dir = os.path.join("/tmp", "install")
    creds_dir = os.path.join("/tmp", "cco-creds")
    for l in [base_dir, creds_dir]:
        try:
            shutil.rmtree(l)
        except:
            pass
        os.makedirs(l)
    
    # get the oc command
    bucket = "private-cluster-installer-resources"
    key = "openshift-install.tar.gz"
    input_tar_file = s3_client.get_object(Bucket = bucket, Key = key)
    input_tar_content = input_tar_file['Body'].read()
    with tarfile.open(fileobj = BytesIO(input_tar_content)) as tar:
        for tar_resource in tar:
            if (tar_resource.isfile()):
                inner_file_bytes = tar.extractfile(tar_resource).read()
                with open(os.path.join(base_dir, tar_resource.name),  "wb") as f:
                    f.write(inner_file_bytes)
   
    # get the template
    template_bytes = s3_client.get_object(Bucket = bucket, Key = "install-config-template.yaml")["Body"].read()
    with open(os.path.join(base_dir, "install-config.yaml"), "wb") as f:
        f.write(template_bytes)
        
    # get the ccoctl
    template_bytes = s3_client.get_object(Bucket = bucket, Key = "ccoctl")["Body"].read()
    with open(os.path.join(base_dir, "ccoctl"), "wb") as f:
        f.write(template_bytes)
        subprocess.run(["chmod", "+x", os.path.join(base_dir, "ccoctl")])
    
    # get the credential files for the cco
    creds = [
        "0000_50_cluster-storage-operator_03_credentials_request_aws.yaml",
        "0000_50_cluster-ingress-operator_00-ingress-credentials-request.yaml",
        "0000_50_cluster-image-registry-operator_01-registry-credentials-request.yaml",
        "0000_50_cloud-credential-operator_05-iam-ro-credentialsrequest.yaml",
        "0000_30_machine-api-operator_00_credentials-request.yaml"
    ]


    for k in creds:
        template_bytes = s3_client.get_object(Bucket = bucket, Key = k)["Body"].read()
        with open(os.path.join(creds_dir, k), "wb") as f:
            f.write(template_bytes) 

    # run manifest creation
    subprocess.run(["chmod", "+x", "./create-manifests.sh"])
    subprocess.run(["sh", "./create-manifests.sh", base_dir, creds_dir])
    
    #upload generated media to s3
    json_files = ["metadata.json", "bootstrap.ign", "master.ign", "worker.ign"]
    for root,dirs,files in os.walk(base_dir):
        for file in files:
            extra_args = {}
            if file in json_files:
                extra_args={'ContentType': "application/json"}
            s3_client.upload_file(os.path.join(root,file), bucket, file, ExtraArgs=extra_args)