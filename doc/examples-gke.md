## Getting Started

### TL;DR
1. create a repository for your CI/CD use
2. clone this repository
3. create a dedicated runner (public or private)
4. update the scripting (as defined in the commentary) for your cluster
5. run the service deployment

## 💁 The Google Cloud CPE workflow will:

The GKE specific workflow for GitHub Actions can be found [here](/.github/workflows/deploy_service_gke.yaml).

- Parse inputs: service for deployment, namespace, helm-repo, command
- Check for required secrets
- Checkout your repository
- Install gcloud cli and helm chart tools
- Add helm repository
- Perform GKE cluster login
- Perform helm install/uninstall/validate for service

## ℹ️ Configure your repository and the workflow with the following steps:
1. Have access to an GKE cluster. Refer to https://cloud.google.com/kubernetes-engine/docs/quickstart
2. Set up secrets in your workspace: `GKE_PROJECT` with the name of the project, `GKE_SA_KEY` with the Base64 encoded JSON service account key, `IMAGE_REGISTRY`, `IMAGE_REGISTRY_TOKEN`, and `HELM_REGISTRY_TOKEN` repository secrets. 

Refer to:
> - https://github.com/GoogleCloudPlatform/github-actions/tree/docs/service-account-key/setup-gcloud#inputs
> - https://docs.github.com/en/actions/reference/encrypted-secrets
> - https://cli.github.com/manual/gh_secret_set
3. (Optional) Edit the top-level `env` section as marked with '🖊️' if the defaults are not suitable for your project.
4. Commit and push the workflow file to your default branch. Manually trigger a workflow run.


## 📃 Considerations
Image registry should be added to cluster in corresponding namespace before workflow run.

Example:
```
 kubectl create secret docker-registry pullsecret \
--docker-server=repository.path \
--docker-username=user --docker-password=token
```