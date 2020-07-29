#!/bin/bash

pushd ./terraform/state

terraform init \
  -input=false \
  ../root/project \
  && \
terraform plan \
  -destroy \
  -input=false \
  -var-file=./rancher-creds.tfvars \
  -state=./project.tfstate \
  -out ./project.plan.zip \
  ../root/project \
  && \
terraform apply \
  -state=./project.tfstate \
  ./project.plan.zip \
  && \
terraform init \
  -input=false \
  ../root/tooling \
  && \
terraform plan \
  -destroy \
  -input=false \
  -var-file=./rancher-creds.tfvars \
  -var-file=./tooling-config.tfvars \
  -state=./tooling.tfstate \
  -out ./tooling.plan.zip \
  ../root/tooling \
  && \
terraform apply \
  -state=./tooling.tfstate \
  ./tooling.plan.zip

popd
