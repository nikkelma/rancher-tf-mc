terraform {
  required_providers {
    rancher2 = {
      "source"  = "rancher/rancher2"
      "version" = "~> 1.9"
    }
    random = {
      "source"  = "hashicorp/random"
      "version" = "~> 2.3"
    }
  }
  required_version = ">= 0.13"
}
