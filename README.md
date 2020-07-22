# Rancher Master Class: Terraform

This is the PRIVATE repository for the Rancher Terraform master class - if
anything is marked PRIVATE, it shouldn't be in the public version!

## Create a Rancher server

I've chosen to use k3s as the Kubernetes cluster where Rancher is installed, mainly because I wanted
to avoid using the RKE terraform provider (`terraform-provider-rke`).

`terraform-provider-rke` is best effort support under the Rancher SLA and, while it works well, the
patterns currently used by RKE (and therefore `terraform-provider-rke`) will end as soon as RKE2 is
released. RKE2 will use patterns very similar to K3S, so those patterns are demonstrated here.

Finally, we're in the process of allowing Rancher to be installed into any Kubernetes cluster. That
means the underlying distribution of k8s will matter much less, and therefore the "create a cluster"
portion of installing a Rancher server will also be deemphasized.

K3S requires an external HA datastore for full HA functionality, which is required for a Rancher
server. The easiest path to this is a managed database service, like Amazon's RDS.

All Rancher servers are best load balanced by a layer 4 load balancer, so Amazon's NLB will be used
for this purpose. Best practices require a trusted SSL certificate to be used, so Let's Encrypt
will be used when installing Rancher.

