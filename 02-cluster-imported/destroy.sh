#!/bin/bash

pushd ./terraform/state

export tf_var_aks_cluster_resource_group_name=$(terraform output -state=./cluster.tfstate resource_group_name) \
  && \
export tf_var_aks_cluster_name=$(terraform output -state=./cluster.tfstate cluster_name) \
  && \
export tf_var_prefix=$(terraform output -state=./cluster.tfstate prefix) \
  && \
terraform init \
  -input=false \
  ../root/import \
  && \
terraform plan \
  -destroy \
  -input=false \
  -var-file=./azure-creds.tfvars \
  -var-file=./rancher-creds.tfvars \
  -var="aks_cluster_resource_group_name=${tf_var_aks_cluster_resource_group_name}" \
  -var="aks_cluster_name=${tf_var_aks_cluster_name}" \
  -var="rancher_cluster_name=tf-mc-imported-${tf_var_prefix}" \
  -state=./import.tfstate \
  -out ./import.plan.zip \
  ../root/import \
  && \
terraform apply \
  -state=./import.tfstate \
  ./import.plan.zip \
  && \
terraform init \
  -input=false \
  ../root/cluster \
  && \
terraform plan \
  -destroy \
  -input=false \
  -var-file=./azure-creds.tfvars \
  -state=./cluster.tfstate \
  -out ./cluster.plan.zip \
  ../root/cluster \
  && \
terraform apply \
  -state=./cluster.tfstate \
  ./cluster.plan.zip

popd
