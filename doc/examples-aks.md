## Getting Started

### TL;DR
1. create a repository for your CI/CD use
2. clone this repository
3. create a dedicated runner (public or private)
4. update the scripting (as defined in the commentary) for your cluster
5. run the service deployment

## 💁 The Azure AKS CPE workflow will:

The AKS specific workflow for GitHub Actions can be found [here](/.github/workflows/deploy_service_aks.yaml).

- Parse inputs: service for deployment, namespace, helm-repo, command
- Check for required secrets
- Checkout your repository
- Install az cli and helm chart tools
- Add helm repository
- Perform AKS cluster login
- Perform helm install/uninstall/validate for service

## ℹ️ Configure your repository and the workflow with the following steps:
1. Have access to an AKS cluster. Refer to https://docs.microsoft.com/en-us/azure/aks/
2. Set up secrets in your workspace:
- AZURE_CREDENTIALS (see https://github.com/marketplace/actions/azure-login)
- user credentials for your private helm and image registries

Refer to:   

> - https://github.com/marketplace/actions/azure-login#configure-a-service-principal-with-a-secret
> - https://docs.github.com/en/actions/reference/encrypted-secrets
> - https://cli.github.com/manual/gh_secret_set
3. (Optional) Edit the top-level 'env' section as marked with '🖊️' if the defaults are not suitable for your project.
4. Commit and push the workflow file to your default branch. Manually trigger a workflow run.
## 📃 Considerations
Image registry should be added to cluster in corresponding namespace before workflow run.

Example:
```
 kubectl create secret docker-registry pullsecret \
--docker-server=repository.path \
--docker-username=user --docker-password=token
```



