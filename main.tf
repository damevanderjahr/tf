# ========================================================================
# Construct GKE cluster
# ========================================================================
module "gke_cluster" {
  source           = "github.com/damevanderjahr/tf-google-gke-cluster"
  GOOGLE_REGION    = var.GOOGLE_REGION
  GOOGLE_PROJECT   = var.GOOGLE_PROJECT
  GKE_NUM_NODES    = var.GKE_NUM_NODES
  GKE_MACHINE_TYPE = var.GKE_MACHINE_TYPE
}

# ========================================================================
# Construct KinD cluster
# ========================================================================
# resource "kind_cluster" "this" {
#   name = "flux-kind-cluster"
# }

# ========================================================================
# Construct TLS key
# ========================================================================
module "tls_private_key" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"

  algorithm   = var.algorithm
  ecdsa_curve = var.ecdsa_curve
}

# ========================================================================
# Construct TLS key
# ========================================================================
module "github_repository" {
  source                   = "./modules/github_repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux-ssh-pub"
  GCP_PROJECT_ID           = var.GOOGLE_PROJECT
  GCP_SA_JSON              = var.GCP_SA_JSON
  GCP_SECRET_NAME          = "TELE_TOKEN"
}

# ========================================================================
# Bootstrup Flux
# ========================================================================
resource "flux_bootstrap_git" "this" {
  depends_on = [
    module.gke_cluster,
    module.tls_private_key,
    module.github_repository
  ]

  path = "clusters"
}

# ========================================================================
# Commit Flux kbot configs
# ========================================================================
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
      cp -r demo_app/demo ${var.FLUX_GITHUB_REPO}/${var.FLUX_GITHUB_TARGET_PATH}/   
      cp -r demo_app/flux-system ${var.FLUX_GITHUB_REPO}/${var.FLUX_GITHUB_TARGET_PATH}/
      cp -r demo_app/.github ${var.FLUX_GITHUB_REPO}/
      cp demo_app/secrets-template.yaml ${var.FLUX_GITHUB_REPO}/
      cd ${var.FLUX_GITHUB_REPO}
      git add .
      git commit -m "Added all manifests"
      git push
      cd ..
      rm -rf ${var.FLUX_GITHUB_REPO}
    EOF
  }
}

# ========================================================================
# Commit Add kbot namespace and secret
# ========================================================================
# resource "kubernetes_namespace" "demo" {
#   metadata {
#     name = "demo"
#   }

#   lifecycle {
#     ignore_changes = [metadata]
#   }

#   depends_on = [
#     resource.flux_bootstrap_git.this,
#     module.gke_cluster
#   ]
# }

# resource "kubernetes_secret" "kbot_token" {
#   metadata {
#     name      = "kbot"
#     namespace = "demo"
#   }

#   type = "Opaque"

#   data = {
#     "token" = var.TELE_TOKEN
#   }

#   depends_on = [
#     resource.flux_bootstrap_git.this,
#     resource.kubernetes_namespace.demo
#   ]
# }
