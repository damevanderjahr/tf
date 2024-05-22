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
| GCP_SA_JSON | GCP service account credentials to import to GitHub secrets to support SOPS flow | string | no | yes |

Attention: 2 x e2-medium node pool seems the minimal working configuration for Flux.

## Tokens and credentials without SOPS flow

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

## SOPS flow

main.tf content is actual not for the firts terraform apply run, because we cant delete key-connected GCP assets

```bash
# export token and GCP credentials
read -s GITHUB_TOKEN
export GITHUB_TOKEN
export CREDS=$(cat /your/path/credentials.json)

# Import keyring and keys if not the first run
terraform import -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS" "module.kms.google_kms_key_ring.key_ring" "projects/smiling-tide-422119-d5/locations/global/keyRings/sops-flux"

terraform import -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS" "module.kms.google_kms_crypto_key.key[0]" "projects/smiling-tide-422119-d5/locations/global/keyRings/sops-flux/cryptoKeys/sops-key-flux"

# plan and apply
terraform plan -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS"
terraform apply -var-file vars.tfvars  -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS"

# Move configs to the flux-gitops clonned repo (Attention - gcp sa is hard-coded)
cp -r demo_app/demo ../flux-gitops/clusters/
cp -r demo_app/flux-system/ ../flux-gitops/clusters/
cp -r demo_app/.github ../flux-gitops/
cp demo_app/secret-template.yaml ../flux-gitops/
# commit "Added all manifests"

# check deployment
export KUBECONFIG=.terraform/modules/gke_cluster/kubeconfig
kubectl get sa -n flux-system kustomize-controller -o yaml
kubectl get deployments.apps -n demo

# remove assets from the Terraform state to save from destroy:
terraform state rm $(terraform state list | grep module.github_repository)
terraform state rm flux_bootstrap_git.this
terraform state rm module.tls_private_key.tls_private_key.this
terraform state list

# destroy
terraform destroy -var-file vars.tfvars -var="GITHUB_TOKEN=$GITHUB_TOKEN" -var="GCP_SA_JSON=$CREDS"
```

## Monitoring

Local env tuning

```bash
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

```bash
export METRICS_HOST="otel-collector-collector.monitoring.svc.cluster.local:4317"
kubectl create secret generic kbot-m -n demo \
    --from-literal=address="$METRICS_HOST"
```
