#!/bin/bash

PRIVATE_CLOUD="my_private_cloud"
ZONE="us-central1-a"
PROJECT="my_project_id"

CREDENTIALS_TFVARS="gcve.credentials.auto.tfvars"
VM_CREATE_SCRIPT="create_vms.sh"

VCENTER_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(vcenter.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT ) 
VCENTER_USER=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
VCENTER_PWD=$(gcloud vmware private-clouds vcenter credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")


NSX_IP=$(gcloud vmware private-clouds list --location=$ZONE --format="value(nsx.internalIp)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT )
NSX_URL=$(gcloud vmware private-clouds list --location=$ZONE --format="value(nsx.fqdn)" --filter="name=projects/$PROJECT/locations/$ZONE/privateClouds/$PRIVATE_CLOUD" --project $PROJECT )
NSX_USER=$(gcloud vmware private-clouds nsx credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(username)")
NSX_PWD=$(gcloud vmware private-clouds nsx credentials describe --private-cloud=$PRIVATE_CLOUD --location=$ZONE --project $PROJECT --format="value(password)")


if test -f "$CREDENTIALS_TFVARS"; then
    echo "$CREDENTIALS_TFVARS exists."
else
    echo "create $CREDENTIALS_TFVARS"	
    cp $CREDENTIALS_TFVARS.template $CREDENTIALS_TFVARS
fi

if test -f "$VM_CREATE_SCRIPT"; then
    echo "$VM_CREATE_SCRIPT exists."
else
    echo "create $VM_CREATE_SCRIPT"
    cp $VM_CREATE_SCRIPT.template $VM_CREATE_SCRIPT
fi


sed -i  "s/vsphere_server.*/vsphere_server   = \"$VCENTER_URL\"/g" $CREDENTIALS_TFVARS 
sed -i "s/vsphere_user.*/vsphere_user     = \"$VCENTER_USER\"/g" $CREDENTIALS_TFVARS
sed -i "s/vsphere_password.*/vsphere_password = \"$VCENTER_PWD\"/g" $CREDENTIALS_TFVARS
sed -i "s/vcenter_ip_address.*/vcenter_ip_address     = \"$VCENTER_IP\"/g" $CREDENTIALS_TFVARS
sed -i "s/nsx_manager_ip_address.*/nsx_manager_ip_address = \"$NSX_IP\"/g" $CREDENTIALS_TFVARS


sed -i "s/nsxt_password.*/nsxt_password = \"$NSX_PWD\"/g" $CREDENTIALS_TFVARS
sed -i "s/nsxt_url.*/nsxt_url = \"$NSX_URL\"/g" $CREDENTIALS_TFVARS


sed -i  "s/GOVC_URL.*/GOVC_URL=https:\/\/$VCENTER_URL\/sdk/g" $VM_CREATE_SCRIPT 
sed -i  "s/GOVC_USERNAME.*/GOVC_USERNAME=$VCENTER_USER/g" $VM_CREATE_SCRIPT
sed -i "s/GOVC_PASSWORD.*/GOVC_PASSWORD=$VCENTER_PWD/g" $VM_CREATE_SCRIPT

terraform init
