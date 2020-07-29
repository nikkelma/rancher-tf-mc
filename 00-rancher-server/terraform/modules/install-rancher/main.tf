provider "rancher2" {
  alias = "bootstrap"
}

resource "kubernetes_service_account" "cert_manager_crd" {
  metadata {
    name      = "cert-manager-crd"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "cert_manager_crd_admin" {
  metadata {
    name = "${kubernetes_service_account.cert_manager_crd.metadata[0].name}-admin"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_manager_crd.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_job" "create_cert_manager_ns" {
  depends_on = [
    kubernetes_cluster_role_binding.cert_manager_crd_admin,
  ]

  metadata {
    name      = "create-cert-manager-ns"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "kubectl"
          image = "${var.kubectl_image}:${var.kubectl_tag}"
          command = [
            "kubectl",
            "create",
            "namespace",
            "cert-manager",
          ]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.cert_manager_crd.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
}

resource "kubernetes_job" "install_certmanager_crds" {
  metadata {
    name      = "install-certmanager-crds"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "kubectl"
          image = "${var.kubectl_image}:${var.kubectl_tag}"
          command = [
            "kubectl",
            "apply",
            "--validate=false",
            "-f",
            var.cert_manager_crd_manifest_url,
          ]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.cert_manager_crd.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
}

resource "kubernetes_job" "create_cattle_system_ns" {
  metadata {
    name      = "create-cattle-system-ns"
    namespace = "kube-system"
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "kubectl"
          image = "${var.kubectl_image}:${var.kubectl_tag}"
          command = [
            "kubectl",
            "create",
            "namespace",
            "cattle-system",
          ]
        }
        host_network                    = true
        automount_service_account_token = true
        service_account_name            = kubernetes_service_account.cert_manager_crd.metadata[0].name
        restart_policy                  = "Never"
      }
    }
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_job.create_cert_manager_ns,
    kubernetes_job.install_certmanager_crds,
    kubernetes_service_account.cert_manager_crd,
    kubernetes_cluster_role_binding.cert_manager_crd_admin,
  ]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version
  namespace  = "cert-manager"
  wait       = true
}

resource "helm_release" "rancher" {
  depends_on = [
    helm_release.cert_manager,
    kubernetes_job.create_cattle_system_ns,
  ]

  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/${var.rancher_release_channel}"
  chart      = "rancher"
  version    = var.rancher_version
  namespace  = "cattle-system"

  set {
    name  = "hostname"
    value = var.rancher_hostname
  }

  dynamic "set" {
    for_each = var.rancher_sets
    content {
      name  = set.value["name"]
      value = set.value["value"]
      type  = set.value["type"]
    }
  }
}


resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  depends_on = [
    helm_release.rancher,
  ]

  password  = var.rancher_password
  telemetry = true
}
