# module "gke_cluster" {
#   source         = "github.com/damevanderjahr/tf-google-gke-cluster"
#   GOOGLE_REGION  = var.GOOGLE_REGION
#   GOOGLE_PROJECT = var.GOOGLE_PROJECT
#   GKE_NUM_NODES  = 2
# }

# ========================================================================
# Construct KinD cluster
# ========================================================================
resource "kind_cluster" "this" {
  name = "flux-kind-cluster"
}

module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"

  #algorithm   = var.algorithm
  #ecdsa_curve = var.ecdsa_curve
}

module "github_repository" {
  source                   = "./modules/github_repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux-ssh-pub"
}


# provider "flux" {
#   kubernetes = {
#     config_path = module.kind_cluster.kubeconfig
#   }
#   git = {
#     url = "ssh://git@github.com/${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}.git"
#     ssh = {
#       username    = "git"
#       private_key = module.tls_private_key.private_key_pem
#     }
#   }
# }

# ========================================================================
# Manage the SSH keypair flux uses to authenticate with GitHub
# ========================================================================

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "ssh_keypair" {
  metadata {
    name      = "flux-system"
    namespace = "flux-system"
  }

  type = "Opaque"

  data = {
    "identity.pub" = module.tls_private_key.public_key_openssh
    "identity"     = module.tls_private_key.private_key_pem
    "known_hosts"  = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  }

  depends_on = [kubernetes_namespace.flux_system]
}

resource "flux_bootstrap_git" "this" {
  depends_on = [
    resource.kind_cluster.this,
    module.tls_private_key,
    module.github_repository
  ]

  path = "clusters"
}


resource "null_resource" "git_commit" {
  depends_on = [
    resource.flux_bootstrap_git.this
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

# resource "null_resource" "create_secret" {
#   depends_on = [
#     resource.null_resource.git_commit
#   ]

#   provisioner "local-exec" {
#     command = <<EOF
#       while [ $(kubectl get namespaces --kubeconfig=${module.kind_cluster.kubeconfig} | grep demo | wc -l) -eq 0 ]; do
#         sleep 5
#       done
#       kubectl create secret generic kbot \
#         --from-literal=token=${var.TELE_TOKEN}\
#         -n demo \
#         --kubeconfig=${module.kind_cluster.kubeconfig}
#     EOF
#   }
# }
