variable "github_owner" {
  type        = string
  description = "The GitHub owner"
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
}

variable "repository_name" {
  type        = string
  default     = "flux-gitops"
  description = "GitHub repository"
}

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "The visibility of the GitOps repository"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "GitHub branch"
}

variable "public_key_openssh" {
  type        = string
  description = "OpenSSH public key repository access"
}

variable "public_key_openssh_title" {
  type        = string
  description = "The title for OpenSSH public key"
}

# variable "GCP_PROJECT_ID" {
#   type        = string
#   description = "GCP_PROJECT_ID secret"
# }

# variable "GCP_SA_JSON" {
#   type        = string
#   description = "GCP_SA_JSON secret"
# }

# variable "GCP_SECRET_NAME" {
#   type        = string
#   description = "GCP_SECRET_NAME secret"
# }