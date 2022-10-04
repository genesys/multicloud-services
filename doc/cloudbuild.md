
## Getting Started
We have included the Cloud Build configuration file for automated deployment to your Google GKE cluster

Read more about it: https://cloud.google.com/build/docs#docs

## Prerequisites

- your Cloud Build service account (named like <PROJECT_NUMBER>@cloudbuild.gserviceaccount.com)
- should have following roles (make sure to add in GCP IAM):
  - Kubernetes Engine Admin
  - Secret Manager Secret Accessor (if using GCP Secret Manager)
  - Logging Admin (to observe pipeline logs in runs history)
- your custom builder image should have installed: `kubectl`, `helm3`, `yq`


<details open>
  <summary style="font-size:16px">Custom Builder Image</summary>
  
### Process
1. Build your image to use with the cloudbuild, [details](https://cloud.google.com/build/docs/configuring-builds/create-basic-configuration)
2. Update your `cloudbuild.yaml` with the PROJECT_ID and name chosen in step 1.

#### Build container reference
📝 Our examples use `gcpe0003` and `privateedition` respectively. 

```yaml
steps:
- id: 'Build Private Edition Customer Builder'
  name: 'gcr.io/cloud-builders/docker'
  args: ['build', '--tag=gcr.io/$PROJECT_ID/privateedition:latest', '-f', './Dockerfile', '.']
  timeout: '3600s'
images:
  - 'gcr.io/$PROJECT_ID/privateedition:latest'
```
</details>

<details open>
  <summary style="font-size:16px">Create Cloud Build trigger</summary>

## Create Cloud Build trigger

GCloud Supports both manual creation of build triggers in the Consul UI as well as using gcloud api.

📝 Our examples use `gcpe0003` and `us-east1`  respectively. 

### Prerequisites:
- Connect source repo to gcloud cloud build [details](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers#connect_repo)  
- GCloud service account (named like <PROJECT_NUMBER>@cloudbuild.gserviceaccount.com)
- Service account has the following roles (make sure to add in GCP IAM):
  - Kubernetes Engine Admin
  - Secret Manager Secret Accessor (if using GCP Secret Manager)
  - Logging Admin (to observe pipeline logs in runs history)

### Input VARS
- **CLUSTER**: Cluster short name
- **IMAGEREGISTRY**: Docker image Registry
- **ARTIFACTREPO**: Helm Release registry
- **DOMAIN**: domain used in creation of ingress objects to resolve external IP
- **GCPPROJECT**: name of GCP project of deployed GKE cluster
- **GCPREGION**: GCP region of deployed GKE cluster

### Source values: 

- **gitFileSource.uri**: Source code repo link (github)
- **gitFileSource.path**: CloudBuild yaml file path inside source repo
- **revision**: source branch
- **sourceToBuild.uri**: Source code repo link (github)
- **sourceToBuild.ref**: source branch

### Manual

Specific manual steps can be found here:

 [Creating a build trigger](https://cloud.google.com/build/docs/automating-builds/create-manage-triggers#build_trigger)

### GCloud API
📝 requires OAuth 2.0 authentication to gcloud using valid service account.

[GCloud API](https://cloud.google.com/build/docs/api/reference/rest/v1/projects.triggers)

https://cloudbuild.googleapis.com/v1/projects/$project_name/triggers

```http
curl --location --request POST 'https://cloudbuild.googleapis.com/v1/projects/gcpe0003/triggers?access_token=<token>' \
--header 'Content-Type: application/json' \
```
**--data-raw**
```json
{
    "description": "Deploys GAUTH PE Services",
    "substitutions": {
        "_VGKECLUSTER": "gke2",
        "_VHELMCOMMAND": "install",
        "_VIMAGEREGISTRY": "pureengage-docker-staging.jfrog.io",
        "_VARTIFACTREPO": "helm-staging",
        "_VDOMAIN": "nlb02-useast1.gcpe003.gencpe.com",
        "_VGCPPROJECT": "gcpe0003",
        "_VGCPREGION": "us-east1"
    },
    "tags": [
        "PE-Stack-GAUTH-gke3-2"
    ],
    "name": "01-gauth-deployment",
    "gitFileSource": {
        "path": "cloudbuild.yaml",
        "uri": "<Source_Code_Repo_Link>",
        "repoType": "GITHUB",
        "revision": "refs/heads/development"
    },
    "sourceToBuild": {
        "uri": "<Source_Code_Repo_Link>",
        "ref": "refs/heads/<ranch>",
        "repoType": "GITHUB"
    },
    "serviceAccount": "projects/gcpe0003/serviceAccounts/402866575973-compute@developer.gserviceaccount.com"
}
```
</details>
