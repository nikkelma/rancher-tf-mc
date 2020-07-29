#!/bin/bash

pushd ./terraform/state

terraform init \
  -input=false \
  ../root/cluster \
  && \
terraform plan \
  -input=false \
  -var-file=./do-creds.tfvars \
  -var-file=./rancher-creds.tfvars \
  -state=./cluster.tfstate \
  -out ./cluster.plan.zip \
  ../root/cluster \
  && \
terraform apply \
  -state=./cluster.tfstate \
  ./cluster.plan.zip

popd
