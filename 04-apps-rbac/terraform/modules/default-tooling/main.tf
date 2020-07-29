
locals {
  longhorn_answers_default = {
    "csi.attacherReplicaCount"                          = ""
    "csi.kubeletRootDir"                                = ""
    "csi.provisionerReplicaCount"                       = ""
    "defaultSettings.autoSalvage"                       = "true"
    "defaultSettings.backupTarget"                      = ""
    "defaultSettings.backupTargetCredentialSecret"      = ""
    "defaultSettings.backupstorePollInterval"           = "300"
    "defaultSettings.createDefaultDiskLabeledNodes"     = "false"
    "defaultSettings.defaultDataPath"                   = "/var/lib/longhorn/"
    "defaultSettings.defaultLonghornStaticStorageClass" = "longhorn-static"
    "defaultSettings.defaultReplicaCount"               = "3"
    "defaultSettings.disableSchedulingOnCordonedNode"   = "true"
    "defaultSettings.guaranteedEngineCPU"               = "0.25"
    "defaultSettings.mkfsExt4Parameters"                = ""
    "defaultSettings.priorityClass"                     = ""
    "defaultSettings.registrySecret"                    = ""
    "defaultSettings.replicaSoftAntiAffinity"           = "false"
    "defaultSettings.replicaZoneSoftAntiAffinity"       = "true"
    "defaultSettings.storageMinimalAvailablePercentage" = "25"
    "defaultSettings.storageOverProvisioningPercentage" = "200"
    "defaultSettings.taintToleration"                   = ""
    "defaultSettings.upgradeChecker"                    = "true"
    "defaultSettings.volumeAttachmentRecoveryPolicy"    = "wait"
    "image.defaultImage"                                = "true"
    "ingress.enabled"                                   = "false"
    "longhorn.default_setting"                          = "true"
    "persistence.defaultClass"                          = "true"
    "persistence.defaultClassReplicaCount"              = "3"
    "privateRegistry.registryPasswd"                    = ""
    "privateRegistry.registryUrl"                       = ""
    "privateRegistry.registryUser"                      = ""
    "service.ui.type"                                   = "ClusterIP"
  }
}

data "rancher2_cluster" "target" {
  name = var.cluster_name
}

resource "rancher2_namespace" "longhorn_system" {
  name       = "longhorn-system"
  project_id = data.rancher2_cluster.target.system_project_id
}

resource "rancher2_app" "longhorn" {
  depends_on = [
    rancher2_namespace.longhorn_system,
  ]

  catalog_name     = "library"
  name             = "longhorn"
  project_id       = data.rancher2_cluster.target.system_project_id
  target_namespace = "longhorn-system"
  template_name    = "longhorn"
  template_version = var.longhorn_version
  answers = merge(
    var.longhorn_answers,
    local.longhorn_answers_default,
  )
}

resource "rancher2_catalog" "jetstack" {
  name       = "jetstack"
  url        = "https://charts.jetstack.io"
  scope      = "cluster"
  cluster_id = data.rancher2_cluster.target.id
  version    = "helm_v3"
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

resource "rancher2_namespace" "cert_manager" {
  name       = "cert-manager"
  project_id = data.rancher2_cluster.target.system_project_id
}

resource "rancher2_app" "cert_manager" {
  depends_on = [
    rancher2_catalog.jetstack,
    kubernetes_job.install_certmanager_crds,
    rancher2_namespace.cert_manager,
  ]

  catalog_name     = "${data.rancher2_cluster.target.id}:jetstack"
  name             = "cert-manager"
  project_id       = data.rancher2_cluster.target.system_project_id
  target_namespace = "cert-manager"
  template_name    = "cert-manager"
  template_version = var.cert_manager_version
}

resource "rancher2_cluster_logging" "target" {
  name       = "elasticsearch"
  cluster_id = data.rancher2_cluster.target.id
  kind       = "elasticsearch"
  elasticsearch_config {
    endpoint      = var.elasticsearch_endpoint
    auth_username = var.elasticsearch_username
    auth_password = var.elasticsearch_password
    ssl_version   = "TLSv1_2" # only needed for idempotent apply
  }
}
