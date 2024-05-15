# Flux bootstrap

## tfvars required

Example: [vars.tfvars.example](vars.tfvars.example)
|       Name       |            Description           |  Type  |     Default     | Required |
|:----------------:|:--------------------------------:|:------:|:---------------:|:--------:|
| GOOGLE_PROJECT   | GCP project ID (not name)                 | string | no              |    yes    |
| GOOGLE_REGION    | GCP region name                  | string | "us-central1-c" |    no    |
| GKE_MACHINE_TYPE | GKE node machine type            | string | "e2-medium"      |    no    |
| GKE_NUM_NODES    | Number of nodes in the node pool | number | 2               |    no    |
| GITHUB_OWNER  | GitHub account owner name | string | no | yes |
| FLUX_GITHUB_REPO | Repo name for Flux config | string | "flux-gitops" | no |

Attention: 2 x e2-medium node pool seems the minimal working configuration for Flux.

## Tokens  

```bash
read -s GITHUB_TOKEN
# enter token with repo create and delete permissions if you need successful terraform destroy process
export GITHUB_TOKEN=$GITHUB_TOKEN

read -s TELE_TOKEN
# enter Telegram bot token to create secrete during terraform apply
export TELE_TOKEN=$TELE_TOKEN
```

## Terraform plan, apply, destroy calls

```bash
terraform plan -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="TELE_TOKEN=$TELE_TOKEN"

terraform apply -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="TELE_TOKEN=$TELE_TOKEN"

terraform destroy -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="TELE_TOKEN=$TELE_TOKEN"
```

## Import keyring and keys

```bash
terraform import -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS" "module.kms.google_kms_key_ring.key_ring" "projects/smiling-tide-422119-d5/locations/global/keyRings/sops-flux"
terraform import -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS" "module.kms.google_kms_crypto_key.key_ephemeral[0]" "projects/smiling-tide-422119-d5/locations/global/keyRings/sops-flux/cryptoKeys/sops-key-flux"
```

## Kubectl config after apply

```bash
export KUBECONFIG=.terraform/modules/gke_cluster/kubeconfig
kubectl get ns
```

## Flux config

Bootstrap will create "flux-gitops" repo in the GitHub account. As additional step, source and release yamls from [demo_app/demo](demo_app/demo) directory would be commited to the new repo.

Flux configured with

```yaml
    reconcileStrategy: Revision
```

not the ChartVersion, to track new main branch commits, not only the new tags in helm chart.
