provider "flux" {
  kubernetes = {
    host                   = module.gke_cluster.host
    token                  = module.gke_cluster.token
    cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
  }
  git = {
    url = module.github_repository.values.http_clone_url
    ssh = {
      username    = "git"
      private_key = module.tls_private_key.private_key_pem
    }
  }
}

provider "kubernetes" {
  host                   = module.gke_cluster.host
  token                  = module.gke_cluster.token
  cluster_ca_certificate = module.gke_cluster.cluster_ca_certificate
}