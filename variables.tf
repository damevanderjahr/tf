# variable "GOOGLE_PROJECT" {
#   type        = string
#   description = "GCP project to use"
# }

# variable "GOOGLE_REGION" {
#   type        = string
#   default     = "us-central1-c"
#   description = "GCP region to use"
# }

# variable "GKE_NUM_NODES" {
#   type        = number
#   default     = 2
#   description = "Number of nodes"
# }

# variable "GKE_MACHINE_TYPE" {
#   type        = string
#   default     = "e2-medium"
#   description = "Machine type"
# }

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
  default     = "flux-gitops-monitoring"
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

variable "algorithm" {
  type        = string
  default     = "ECDSA"
  description = "The cryptographic algorithm (e.g. RSA, ECDSA)"
}

variable "ecdsa_curve" {
  type        = string
  default     = "P256"
  description = "The elliptic curve (e.g. P256, P384, P521)"
}

# variable "GCP_SA_JSON" {
#   type        = string
#   description = "Service account credentials in json"
# }