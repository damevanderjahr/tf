variable "GOOGLE_PROJECT" {
  type        = string
  description = "GCP project to use"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "us-central1-c"
  description = "GCP region to use"
}

variable "GKE_NUM_NODES" {
  type        = number
  description = "Number of nodes"
}


variable "GITHUB_OWNER" {
  type        = string
  description = "GitHub repo owner name (id)"
}

variable "GITHUB_TOKEN" {
  type        = string
  description = "GitHub token with repo permissions"
}

variable "FLUX_GITHUB_REPO" {
  type        = string
  default     = "flux-gitops"
  description = "Flux GitOps repository"
}

variable "FLUX_GITHUB_TARGET_PATH" {
  type        = string
  default     = "clusters"
  description = "Flux manifests subdirectory"
}

variable "config_path" {
  type        = string
  default     = "~/.kube/config"
  description = "The path to the kubeconfig file"
}

variable "github_token" {
  type        = string
  default     = ""
  description = "The token used to authenticate with the Git repository"
}

variable "TELE_TOKEN" {
  type        = string
  description = "Telegram kbot token"
}