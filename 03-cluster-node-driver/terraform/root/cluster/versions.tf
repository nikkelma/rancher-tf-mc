terraform {
  required_providers {
    rancher2 = {
      source = "rancher/rancher2"
    }
    random = {
      source = "hashicorp/random"
    }
  }
  required_version = ">= 0.13"
}
