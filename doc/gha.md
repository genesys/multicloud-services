[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
- [Welcome](#welcome)
  - [TL;DR](#tldr)
  - [Developer Guidance](#developer-guidance)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
  - [self-hosted runners](#self-hosted-runners)
    - [Creating a runner on a host](#creating-a-runner-on-a-host)
    - [Creating a runner within the cluster](#creating-a-runner-within-the-cluster)
  - [Secrets](#secrets)
    - [Cluster specific secret](#cluster-specific-secret)
- [Configuration](#configuration)
  - [Recommendations](#recommendations)
- [Usage](#usage)
  - [Input](#input)
  - [Typical use cases](#typical-use-cases)
    - [validate](#validate)
    - [uninstall](#uninstall)
    - [install](#install)
  - [Troubleshooting](#troubleshooting)

# Welcome
There are many different CI/CD models available for use, we've included details for those we've had opportunity to work with.
- GitHub Actions
## TL;DR
1. create a repository for your CI/CD use
2. clone this repository
3. create a dedicated runner (public or private)
4. update the scripting (as defined in the commentary) for your cluster
5. run the service deployment

## Developer Guidance
If you find something missing, feel free to contribute to any of our documentation files, or write new ones.

This is a work in progress as we learn what we'll need to provide people in order to be effective contributors to our project. 

Be sure to review the following:  
* [Contribution Guidelines](/doc/CONTRIBUTE.md)

# Getting Started

The following is an example framework for the use of GitOPS with Genesys Private Edition deployments. The service deployment pipeline is based on:

- Github workflows and github actions (GHA), located in [.github](../.github/workflows/)
- deployment scripts, located in [services](../services/) 
- and helm packages, delivered by product/service teams and uploaded to your own internal repository

Depending on the command (`install`, `uninstall`, `validate`, `provision`, etc) the workflow performs the action using override values from same components folder. Note: There may be multiple override values files.
# Prerequisites
In order to leverage this model of CI/CD, you will need to have the following configured.
- Image repository
- GitHub repository
- GitHub Actions runner - either [GitHub-hosted](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners), or your own [self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners). * It is recommended to use self-hosted runners with private repositories. 
- GitHub Actions workflow - workflows/ will contain a base template to work from. 

## self-hosted runners
### Creating a runner on a host
- Navigate to <repository>/settings/actions/add-new-runner
- Follow the specific instructions for your operating system and architecture. 

### Creating a runner within the cluster
To use a self-hosted runner within your cluster, we recommend [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) or [actions-runner-operator](https://github.com/evryfs/github-actions-runner-operator/). You can also [build your own runner](/doc/RUNNERS.md) from the public images.


## Secrets

Assign your Pipeline Secrets within GitHub as per:
 - https://docs.github.com/en/actions/reference/encrypted-secrets
 - https://cli.github.com/manual/gh_secret_set

:asterisk: Indicates the variable is mandatory.
|:key: Key|| Default Value | Example| Description
|:-|:-:|:-:|:-:|:-|
HELM_REGISTRY|:asterisk:|-||
HELM_REGISTRY_USER|:asterisk:|-||
HELM_REGISTRY_TOKEN|:asterisk:|-||
IMAGE_REGISTRY|:asterisk:|-|pureengage-docker-staging.jfrog.io|
IMAGE_REGISTRY_USER|:asterisk:|-||
IMAGE_REGISTRY_TOKEN|:asterisk:|-||

### Cluster specific secret

Depending on your cluster type, you will also need to define the cluster specific pipeline secrets. Read over the workflows to learn more.

[**OpenShift** ](/.github/workflows/deploy_service_openshift.yaml)
- `OpenShift_SERVER_ARO`
- `OpenShift_TOKEN_ARO`

[**GKE**](/.github/workflows/deploy_service_gke.yaml)
- `GKE_SA_KEY`
- `GKE_PROJECT`

[**K8s**](/.github/workflows/deploy_service_k8s.yaml)
- `K8S_CONFIG_FILE`

[**Azure**](/.github/workflows/deploy_service_aks.yaml)
- `AZURE_CREDENTIALS`

# Configuration

## Recommendations
It is recommended to separate your override values for installation and provisioning, as well as maintaining separate files for application versions. This allows easier upgrades.

Helm installation on top of existing services does not impact the service, as Kubernetes applies change and restarts pods only if there is real difference between applied manifest and corresponding k8s object.

`github/workflows` contains github actions (GHA) workflows, the sample workflow is based on simple Dispatch mode, when we trigger pipeline manually (see screenshot below) adding a few input parameters.
![image](https://user-images.githubusercontent.com/83649784/162738542-420f3713-3c1a-40d5-8113-a2bf6298d9d0.png)

# Usage
This example pipeline triggers manually in dispatch mode, within Github repo, in "Actions" tab. 
## Input
The minimum set of input is:

- **service for deployment** - defines /services/.. subfolder in repository where all service-specific custom scripts, override values, configuration files are located. It can be list of services separated by space. Or "bulk" keyword for all services deployment at once (see further about Bulk deployment)
- **command to apply** - typically "validate" or "install" or "uninstall", or any other commands supported by this particular deployed service (pipeline developer defines keywords)

Other dispatch-mode inputs are optional:

- **namespace** - you can specify non-default namespace for particular service. Default value is empty and pipeline will use same name as service name (except tenant service - it is deployed in "voice" namespace by default)
- **helm repo in JFrog** - we use "helm-stage" by default, but you can specify "helm-dev" or any other one accessible by URI https://pureengage.jfrog.io/artifactory/

## Typical use cases
When pipeline is triggered for multiple services at once, it will create parallel jobs for every service. These will be independent jobs. Operator can check the status of run (and each job) after the run.
### validate
We go through all steps in pipeline - setup environment, fetching secrets, preparing input for helm and finally running helm upgrade/install but *in Dry-run mode*. So it is good assurance that all input and Helm charts are valid, kubernetes cluster is accessible, and highly likely install or upgrade will succeed.
### uninstall
Normally uninstalls all service-related Helm releases in target namespace, and may also delete objects like routes that are created outside of Helm chart. Note: We  do not recommend deleting Namespace or secrets outside of chart (incl. deployment-secrets, see further).
### install
Most typical use case where we:
- install from scratch (creating project and namespace if not present) 
- or update existing service in target namespace, with changed override values files
- or (as subset of previous case) just upgrade components/applications to new versions via "versions.yaml" file

## Troubleshooting
If at any point there are failures in workflow, the pipeline fails and stdout is saved within the run. You can check it any time (two months is the default retention period).
The following table will help identify some potential issues.

<table class="wrapped confluenceTable"><colgroup><col /><col /><col /><col /></colgroup><tbody><tr><th class="confluenceTh">Steps</th><th class="confluenceTh">Failure</th><th class="confluenceTh">Probable cause</th><th class="confluenceTh">Recommendations</th></tr><tr><td class="confluenceTd"><strong>Initial</strong></td><td class="confluenceTd">Workflow does not even start</td><td class="confluenceTd"><p>wrong syntax of workflow YAML file&nbsp;</p></td><td class="confluenceTd">check last commits to dispatch_deploy.yaml and who did it. May need to revert change</td></tr><tr><td class="confluenceTd"><br /></td><td class="confluenceTd"><br /></td><td class="confluenceTd">no available runners</td><td class="confluenceTd">could be temporary issue</td></tr><tr><td class="confluenceTd"><strong>Strategy matrix</strong></td><td class="confluenceTd">fails to build matrix</td><td class="confluenceTd">input service(s) do not exist</td><td class="confluenceTd">verify&nbsp;service(s) in dispatch input</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Install kubectl CLI</strong></td><td class="confluenceTd" colspan="1">fails to install</td><td class="confluenceTd" colspan="1">network connectivity from runner VM</td><td class="confluenceTd" colspan="1">could be temporary issue</td></tr><tr><td class="confluenceTd" colspan="1"><strong>CLI login</strong></td><td class="confluenceTd" colspan="1">can't login</td><td class="confluenceTd" colspan="1">network issue</td><td class="confluenceTd" colspan="1">could be temporary issue</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">githubuser permissions or expired token</td><td class="confluenceTd" colspan="1">check&nbsp;that guthubuser is present, or may need to update token to github secrets</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Create or use project &amp; ns</strong></td><td class="confluenceTd" colspan="1">can't create</td><td class="confluenceTd" colspan="1">insufficient permissions for service account</td><td class="confluenceTd" colspan="1">check that guthubuser has cluster-admin role</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Helm repo add</strong></td><td class="confluenceTd" colspan="1">auth error</td><td class="confluenceTd" colspan="1">access token expired/disabled</td><td class="confluenceTd" colspan="1">take valid access token from any user, and add to Github secrets</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Run script.sh</strong></td><td class="confluenceTd" colspan="1">helm times out</td><td class="confluenceTd" colspan="1">too low timeout</td><td class="confluenceTd" colspan="1">check if timeout is not too short in scripot.sh</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">waiting for condition</td><td class="confluenceTd" colspan="1"><p>May be problem with starting pod (ex, invalid pull secret, or image not available in container registry)</p><p>Note: Helm does not rollback release if it times out. You deployment may be finally successful. Check manually status of pods and services</p></td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">helm error - helm release already exists</td><td class="confluenceTd" colspan="1">you do install, while release already created</td><td class="confluenceTd" colspan="1">check by "helm ls -n &lt;namespace&gt;". But normally we do "helm upgrade --install" and it will upgrade existing release</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">other helm errors</td><td class="confluenceTd" colspan="1">error in values, k8s object definition, error from k8s cluster</td><td class="confluenceTd" colspan="1">requires review of helm chart, comparing to validated chart version, checking override values (last commits), etc</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">any other shell script errors</td><td class="confluenceTd" colspan="1">other than helm, any other errors in script</td><td class="confluenceTd" colspan="1">check last commits to script.sh</td></tr></tbody></table>