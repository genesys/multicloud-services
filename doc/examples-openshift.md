[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
## Getting Started

### TL;DR
1. create a repository for your CI/CD use
2. clone this repository
3. create a dedicated runner (public or private)
4. update the scripting (as defined in the commentary) for your cluster
5. run the service deployment

## 💁 The OpenShift workflow will:

The OpenShift specific workflow for GitHub Actions can be found [here](/.github/workflows/deploy_service_openshift.yaml).

- Parse inputs: service for deployment, namespace, helm-repo, command
- Check for required secrets
- Checkout your repository
- Install OpenShift cli and helm chart tools
- Add helm repository
- Perform OpenShift cluster login
- Perform helm install/uninstall/validate for service

## ℹ️ Configure your repository and the workflow with the following steps:
1. Have access to an OpenShift cluster. Refer to https://www.openshift.com/try
2. Create the `OpenShift_TOKEN`, `OpenShift_SERVER_ARO` repository secrets. 

Refer to:
> - https://github.com/redhat-actions/oc-login#readme
> - https://docs.github.com/en/actions/reference/encrypted-secrets
> - https://cli.github.com/manual/gh_secret_set


3. Edit the top-level `env` section as marked with `🖊️` if the defaults are not suitable for your project.
4. Commit and push the workflow file to your default branch. Manually trigger a workflow run.

## 📃 Considerations
Image registry should be added to cluster in corresponding namespace before workflow run.

Example:    
```
    oc create secret docker-registry pullsecret \
      --docker-server=repository.path \
      --docker-username=user --docker-password=token
    oc secrets link default pullsecret --for=pull
```