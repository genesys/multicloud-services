[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
# Tools
Here you will find various tools we find useful.
- [configurator](/tools/configurator/): For automatic configuration of the environment `global-deployment-secrets`
- [manual_deployment.sh](#manual_deploymentsh): For manual service deployments using the repository structure.
- [actions-runner-controller](#actions-runner-controller): Convenient setup for your self-hosted GitHub runner
  
## [`manual_deployment.sh`](/manual_deployment.sh) 

This script is intended to assist with quick local deployments, or when developing to debug your current workload.

This can also be useful should your CI/CD runner be unavailable.

### Prerequisites
- [ ] System will need to have appropriate plugins.
  - [ ] `kubectl`, `yq`, `helm`, `oc cli` (if using OpenShift)
- [ ] System will need appropriate variables defined. 
  - [ ] `HELM_REGISTRY_USER`, `HELM_REGISTRY_TOKEN`, `IMAGE_REGISTRY_USER`, `IMAGE_REGISTRY_TOKEN`, `HELM_REGISTRY`, `IMAGE_REGISTRY`, `HELM_REPO_NAME`

### Steps:
1) Log in to target kubernetes cluster.

> ℹ️ This script will NOT log you in to cluster and setup your kube context.

2) Add secrets. Some services require `deployment-secrets` to be manually added prior to deployment, create it if not present. Secret definitions can be reviewed [here](/doc/secrets.md). You can check existing cluster secrets, for example:
    ```
    $ kubectl get secret deployment-secrets -o json | jq '.data | map_values(@base64d)'
    ```
3) Adjust INPUT parameters

> ℹ️ Avoid adding sensitive information in scripts.

4) Run the script: `./manual_deployment.sh`

### Input Parameters  

Parameter|Sample Value|Description
-|-|-
CLUSTER|aro|Cluster to target, see workflow for addition details.
CLUSTER_TYPE|openshift|Select from `openshift`,`gke`,`aks`,`k8s`
SERVICE|nexus|Name of the service you wish to work with.
NS||target namespace, empty by default.
FULLCOMMAND|install|Select from `install`,`uninstall`,`validate`

It will look as below in the script:
```
###################################################################################################
#  INPUT
###################################################################################################

export CLUSTER=aro                  #target cluster
export CLUSTER_TYPE=openshift       #cluster type: [openshift, gke, aks, k8s]
export SERVICE=nexus
export NS=                          #target namespace, empty for default
export FULLCOMMAND="install"
```

## [`actions-runner-controller`](/tools/actions-runner-controller/)

Convenient setup for your self-hosted GitHub runners.

**How-to**: https://github.com/actions-runner-controller/actions-runner-controller

- Install manually in chosen namespace (eg, "tools") by ```./script.sh```
- Follow instructions in script.

ℹ️ You need to add `GITHUB_TOKEN` in your deployment secrets, prior to deployment.
Also if using a custom runner image, you need to include a pull secret (`pullsecret`) in deployment namespace, to allow pulling container image from your private repository.

### Custom Runner Image
It is required to build custom runner image (`summerwind/actions-runner:latest`) as the default image does not contain the necessary tool-kit. (e.g. `kubectl`, `helm` ,`oc cli`, etc.)

Provide your artifactory credentials as exported env variables, as well as your docker repo and resulting image version:
```
export JFROG_USER=xxx
export JFROG_TOKEN=yyy
export RUNNER_IMAGE=<docker_repository>/<image_name>
export STAG=0.0.1
```
You can also then run ```./build_runner.sh```

### Deleting
In order to delete deployment, apply commands:
```
helm uninstall actions-runner-controller
kubectl delete secret controller-manager
```

