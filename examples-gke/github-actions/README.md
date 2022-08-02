![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
The following is an example framework for the use of GitOPS with Genesys Private Edition deployments. 

The service deployment pipeline is based on:

- Github workflows and github actions (GHA), located in .github/
- deployment scripts, located in services/ (dedicated sub-folder for each deployed service)
- and helm packages, delivered by product/service teams and uploaded to your own internal repository

# TL;DR

- create a repository for your CI/CD use
- clone the directory that is relevant to you, for example /examples-gke/github-actions/
- create a dedicated runner (public or private)
- update the scripting (as defined in the commentary) for your cluster
- run the service deployment

Depending on command (eg. install, uninstall, validate, provision, etc) script performs helm validation or helm install, using override values from same component's folder. Note: There may be multiple override values files.

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

# Repository content

# 💁 The Google Cloud CPE workflow will:
- Parse inputs: service for deployment, namespace, helm-repo, command
- Check for required secrets
- Checkout your repository
- Install gcloud cli and helm chart tools
- Add helm repository
- Perform GKE cluster login
- Perform helm install/install/validate for service

# ℹ️ Configure your repository and the workflow with the following steps:
1. Have access to an GKE cluster. Refer to https://cloud.google.com/kubernetes-engine/docs/quickstart
2. Set up secrets in your workspace: GKE_PROJECT with the name of the project, GKE_SA_KEY with the Base64 encoded JSON service account key, IMAGE_REGISTRY, and IMAGE_REGISTRY_TOKEN (optional HELM_REGISTRY_TOKEN) repository secrets. Refer to:
 - https://github.com/GoogleCloudPlatform/github-actions/tree/docs/service-account-key/setup-gcloud#inputs
 - https://docs.github.com/en/actions/reference/encrypted-secrets
 - https://cli.github.com/manual/gh_secret_set
3. (Optional) Edit the top-level 'env' section as marked with '🖊️' if the defaults are not suitable for your project.
4. Commit and push the workflow file to your default branch. Manually trigger a workflow run.

# 📃 Considerations
- Image registry should be added to cluster in coresponding namespace before workflow run
Example:
```
 kubectl create secret docker-registry pullsecret \
--docker-server=repository.path \
--docker-username=user --docker-password=token
```

# Configuration


## For Every Helm Chart
ℹ️ Within each application folder should exist subfolder(s) with the following format: 
`[0-9][0-9]_chart_chart-name` where `chart-name` is name of chart used to install and where digits define the installation order. 
Example of `chart-name` used in command line:
```
helm install RELEASE-NAME helm-repo/chart-name
```
## For Every Helm Release
ℹ️ Within each chart folder should exist subfolder(s) with name the following format: 
`[0-9][0-9]_release_release-name` where `release-name` is the name of the release to install and where digits define the installation order. 
Example of `release-name` used in command line:
```
helm install release-name helm-repo/chart-name
```
- If you want to run some preparation scripts (example: initialize database, check conditions) before installing, place the code in `pre-relese-script.sh` within the  release subfolder.
- If you want to run some post-installion scripts (example: validate conditions), place the code in `post-relese-script.sh` within the release subfolder.

It is recommended to separate your override values for installation and provisioning, as well as maintaining separate files for application versions. This allows easier upgrades - you will only need to update file `versions.yaml` for example, and run install command.

Helm installation on top of existing service does not impacting service, as Kubernetes applies change and restarts pods only if there is real difference between applied manifest and corresponding k8s object.

`github/workflows` contains github actions (GHA) workflows, the sample workflow is based on simple Dispatch mode, when we trigger pipeline manually (see screenshot below) adding a few input parameters.
![image](https://user-images.githubusercontent.com/83649784/162738542-420f3713-3c1a-40d5-8113-a2bf6298d9d0.png)

# Usage
Pipeline triggers manually in dispatch mode, within Github repo, in "Actions" tab. Minimum set of input is:

- **service for deployment** - defines /services/.. subfolder in repository where located all service-specific custom scripts, override values, configuration files, etc. It can be list of services separated by space. Or "bulk" keyword for all services deployment at once (see further about Bulk deployment)
- **command to apply** - typically "validate" or "install" or "uninstall", or any other commands supported by this particular deployed service (pipeline developer defines keywords)

Other dispatch-mode inputs are optional:

- **namespace** - you can specify non-default namespace for particular service. Default value is empty and pipeline will use same name as service name (except tenants service - it is deployed in "voice" namespace by default)
- **helm repo in JFrog** - we use "helm-stage" by default, but you can specify "helm-dev" or any other one accessible by URI, this should point to your internal image repository.

# Typical use cases
When pipeline is triggered for multiple services at once, it will create parallel jobs for every service. These will be independent jobs. Operator can check the status of run (and each job) after the run.
## validate
We go through all steps in pipeline - setup environment, fetching secrets, preparing input for helm and finally running helm upgrade/install but *in Dry-run mode*. So it is good assurance that all input and Helm charts are valid, kubernetes cluster is accessible, and highly likely install or upgrade will succeed.
## uninstall
Normally uninstalls all service-related Helm releases in target namespace, and may also delete objects like routes that are created outside of Helm chart. Note: We  do not recommend deleting Namespace or secrets outside of chart (incl. deployment-secrets, see further).
## install
Most typical use case where we:
- install from scratch (creating project and namespace if not present) 
- or update existing service in target namespace, with changed override values files
- or (as subset of previous case) just upgrade components/applications to new versions via "versions.yaml" file

# Additional Information
## Sensitive data and Secrets

We recommend not storing any sensitive data in repository. 
Please use following recommendations:

- remove/blank all sensitive input in override values files - i.e. tokens, client IDs, user credentials (username, password), API keys, etc.
- add all those sensitive inputs in target namespace (you have permissions to it) in secret "deployment-secrets" using OpenShift UI - multiple key/values in same secret object.
- you can create service-specific secret named like "<service>-deployment-secrets" - at it will take precedence over "deployment-secrets" (latter will be ignored). It is convenient when deploying all, or multiple, services in same namespace.
- Ensure your variables do not contain hyphens/dashes, only alphanumeric and underscore symbols.

## Troubleshooting
If at any point we have failure in workflow, pipeline fails and stdout is saved within the run. You can check it any time (two months is default retention period).
The following table will help identify the potential issues.
<table class="wrapped confluenceTable"><colgroup><col /><col /><col /><col /></colgroup><tbody><tr><th class="confluenceTh">Steps</th><th class="confluenceTh">Failure</th><th class="confluenceTh">Probable cause</th><th class="confluenceTh">Recommendations</th></tr><tr><td class="confluenceTd"><strong>Initial</strong></td><td class="confluenceTd">Workflow does not even starts</td><td class="confluenceTd"><p>wrong syntax of workflow YAML file&nbsp;</p></td><td class="confluenceTd">check last commits to dispatch_deploy.yaml and who did it. May need to revert change</td></tr><tr><td class="confluenceTd"><br /></td><td class="confluenceTd"><br /></td><td class="confluenceTd">no available runners</td><td class="confluenceTd">could be temporary issue</td></tr><tr><td class="confluenceTd"><strong>Strategy matrix</strong></td><td class="confluenceTd">fails to build matrix</td><td class="confluenceTd">input service(s) do not exist</td><td class="confluenceTd">verify&nbsp;service(s) in dispatch input</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Install kubectl CLI</strong></td><td class="confluenceTd" colspan="1">fails to install</td><td class="confluenceTd" colspan="1">network connectivity from runner VM</td><td class="confluenceTd" colspan="1">could be temporary issue</td></tr><tr><td class="confluenceTd" colspan="1"><strong>CLI login</strong></td><td class="confluenceTd" colspan="1">can't login</td><td class="confluenceTd" colspan="1">network issue</td><td class="confluenceTd" colspan="1">could be temporary issue</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">githubuser permissions or expired token</td><td class="confluenceTd" colspan="1">check&nbsp;that guthubuser is present, or may need to update token to github secrets</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Create or use project &amp; ns</strong></td><td class="confluenceTd" colspan="1">can't create</td><td class="confluenceTd" colspan="1">insufficient permissions for service account</td><td class="confluenceTd" colspan="1">check that guthubuser has cluster-admin role</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Helm repo add</strong></td><td class="confluenceTd" colspan="1">auth error</td><td class="confluenceTd" colspan="1">access token expired/disabled</td><td class="confluenceTd" colspan="1">take valid access token from any user, and add to Github secrets</td></tr><tr><td class="confluenceTd" colspan="1"><strong>Run script.sh</strong></td><td class="confluenceTd" colspan="1">helm times out</td><td class="confluenceTd" colspan="1">too low timeout</td><td class="confluenceTd" colspan="1">check if timeout is not too short in scripot.sh</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">waiting for condition</td><td class="confluenceTd" colspan="1"><p>May be problem with starting pod (ex, invalid pull secret, or image not available in container registry)</p><p>Note: Helm does not rollback release if it times out. You deployment may be finally successful. Check manually status of pods and services</p></td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">helm error - helm release already exists</td><td class="confluenceTd" colspan="1">you do install, while release already created</td><td class="confluenceTd" colspan="1">check by "helm ls -n &lt;namespace&gt;". But normally we do "helm upgrade --install" and it will upgrade existing release</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">other helm errors</td><td class="confluenceTd" colspan="1">error in values, k8s object definition, error from k8s cluster</td><td class="confluenceTd" colspan="1">requires review of helm chart, comparing to validated chart version, checking override values (last commits), etc</td></tr><tr><td class="confluenceTd" colspan="1"><br /></td><td class="confluenceTd" colspan="1">any other shell script errors</td><td class="confluenceTd" colspan="1">other than helm, any other errors in script</td><td class="confluenceTd" colspan="1">check last commits to script.sh</td></tr></tbody></table>





