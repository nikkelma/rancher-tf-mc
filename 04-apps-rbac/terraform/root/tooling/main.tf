provider "kubernetes" {
  version = "~> 1.11"

  config_path = join("/", [path.cwd, "kube_config.yaml"])
}

provider "local" {
  version = "~> 1.4"
}

provider "rancher2" {
  version = "~> 1.9"

  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}

module "default_tooling" {
  source = "../../modules/default-tooling"

  cluster_name           = var.cluster_name
  elasticsearch_endpoint = var.elasticsearch_endpoint
}
