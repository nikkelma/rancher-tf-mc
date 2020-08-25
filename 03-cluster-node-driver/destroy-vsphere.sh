#!/bin/bash

pushd ./terraform/state

terraform init \
  -input=false \
  ../root/vsphere-cluster \
  && \
terraform plan \
  -destroy \
  -input=false \
  -var-file=./rancher-creds.tfvars \
  -state=./vsphere-cluster.tfstate \
  -out ./vsphere-cluster.plan.zip \
  ../root/vsphere-cluster \
  && \
terraform apply \
  -state=./vsphere-cluster.tfstate \
  ./vsphere-cluster.plan.zip

popd
