# Rancher cluster API object used for import
resource "rancher2_cluster" "target" {
  name = var.rancher_cluster_name
}

# apply import manifest from Rancher cluster
resource "kubernetes_job" "rancher_import" {
  metadata {
    name      = "rancher-import"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name    = "kubectl"
          image   = "${var.kubectl_image}:${var.kubectl_tag}"
          command = split(" ", rancher2_cluster.target.cluster_registration_token.0.command)
        }
        host_network                    = true
        automount_service_account_token = true
        restart_policy                  = "Never"
      }
    }
  }
}
