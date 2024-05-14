provider "github" {
  owner = var.github_owner
  token = var.github_token
}

resource "github_repository" "this" {
  name       = var.repository_name
  visibility = var.repository_visibility
  auto_init  = true
}

resource "github_repository_deploy_key" "this" {
  title      = var.public_key_openssh_title
  repository = github_repository.this.name
  key        = var.public_key_openssh
  read_only  = false
}

resource "github_actions_secret" "GCP_PROJECT_ID" {
  repository       = github_repository.this.name
  secret_name      = "GCP_PROJECT_ID"
  plaintext_value  = var.GCP_PROJECT_ID
}

resource "github_actions_secret" "GCP_SA_JSON" {
  repository       = github_repository.this.name
  secret_name      = "GCP_SA_JSON"
  plaintext_value  = var.GCP_SA_JSON
}

resource "github_actions_secret" "GCP_SECRET_NAME" {
  repository       = github_repository.this.name
  secret_name      = "GCP_SECRET_NAME"
  plaintext_value  = var.GCP_SECRET_NAME
}

# resource "github_actions_repository_permissions" "this" {
#   allowed_actions = "selected"
#   allowed_actions_config {
#     github_owned_allowed = true
#     patterns_allowed     = ["actions/cache@*", "actions/checkout@*"]
#     verified_allowed     = true
#   }
#   repository = github_repository.this.name
# }