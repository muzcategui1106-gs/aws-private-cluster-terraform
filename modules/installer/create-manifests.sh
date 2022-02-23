base_dir=$1
creds_dir=$2

# generated creds dir
generated_creds_dir=/tmp/generated_creds
mkdir -p $generated_creds_dir

# needed by ccoctl
mkdir -p /var/task/manifests

chmod +x $base_dir/ccoctl
chmod +x $base_dir/openshift-install

echo "-----------------------creating ocp base manifests--------------------------"
$base_dir/openshift-install create manifests --dir $base_dir
if [ $? -ne 0 ]; then
    exit 1
fi
ls -ltr $base_dir/
echo "----------------------------------------------------------------------------"

echo "---------------creating creds using ccoctl--------------"
$base_dir/ccoctl aws create-all --name=private-cluster --region=us-east-1 --credentials-requests-dir=$creds_dir --output-dir=$generated_creds_dir
if [ $? -ne 0 ]; then
    exit 1
fi
echo "----------------------------------------------------------------------------"

echo "---------------created cco directory-------------"
ls -ltr $generated_creds_dir/
echo "----------------------------------------------------------------------------"


echo "---------------created cco manifests-------------"
ls -ltr $generated_creds_dir/manifests/
echo "----------------------------------------------------------------------------"

echo "---------------applying cco changes to install media-------------"
cp $generated_creds_dir/manifests/* $base_dir/manifests/
cp -a $generated_creds_dir/tls $base_dir/
echo "----------------------------------------------------------------------------"

echo "---------------creating ignition config-------------"
$base_dir/openshift-install create ignition-configs --dir $base_dir
if [ $? -ne 0 ]; then
    exit 1
fi
echo "----------------------------------------------------------------------------"


# hacks to not have to upload to S3 again
rm $base_dir/openshift-install
rm $base_dir/ccoctl
rm $base_dir/README.md