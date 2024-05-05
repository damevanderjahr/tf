terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.27"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">= 0.4"
    }
  }
}