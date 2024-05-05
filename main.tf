# module "gke_cluster" {
#   source         = "github.com/damevanderjahr/tf-google-gke-cluster"
#   GOOGLE_REGION  = var.GOOGLE_REGION
#   GOOGLE_PROJECT = var.GOOGLE_PROJECT
#   GKE_NUM_NODES  = 2
# }

module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster"
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"

  #algorithm   = var.algorithm
  #ecdsa_curve = var.ecdsa_curve
}

module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux-ssh-pub"
}

module "flux_bootstrap" {
  # depends_on = [
  #   module.kind_cluster,
  #   module.tls_private_key,
  #   module.github_repository
  # ]
  source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  # config_path       = module.gke_cluster.kubeconfig
  config_path       = module.kind_cluster.kubeconfig
  github_token      = var.GITHUB_TOKEN
}

resource "null_resource" "git_commit" {
  depends_on = [
    module.flux_bootstrap
  ]

  provisioner "local-exec" {
    command = <<EOF
      if [ -d ${var.FLUX_GITHUB_REPO} ]; then
        rm -rf ${var.FLUX_GITHUB_REPO}
      fi
      git clone ${module.github_repository.values.http_clone_url}    
      cp -r demo_app/* ${var.FLUX_GITHUB_REPO}/${var.FLUX_GITHUB_TARGET_PATH}/     
      cd ${var.FLUX_GITHUB_REPO}
      git add .
      git commit -m "Added all manifests"
      git push
      cd ..
      rm -rf ${var.FLUX_GITHUB_REPO}
    EOF
  }
}
