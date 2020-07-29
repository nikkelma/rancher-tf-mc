provider "helm" {
  # version = ""

  kubernetes {
    config_path = var.config_path
  }
}

provider "kubernetes" {
  config_path = var.config_path
}

provider "rancher2" {
  alias     = "bootstrap"
  api_url   = "https://${var.rancher_hostname}"
  bootstrap = true
}

module "install_rancher" {
  source = "../../modules/install-rancher"

  providers = {
    helm               = helm
    kubernetes         = kubernetes
    rancher2.bootstrap = rancher2.bootstrap
  }

  rancher_hostname = var.rancher_hostname
  rancher_password = var.rancher_password
  rancher_sets = [
    {
      "name"  = "ingress.tls.source",
      "value" = "letsEncrypt",
      "type"  = "auto",
    },
    {
      "name"  = "letsEncrypt.email",
      "value" = "matt.nikkel@rancher.com",
      "type"  = "auto",
    },
     {
      "name"  = "replicas",
      "value" = "1",
      "type"  = "auto",
    },
  ]
}
