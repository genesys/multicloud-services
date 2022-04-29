# build your own self-hosted runner

## github-actions
You can use:

- github-provided runners (their Azure-deployed VMs) like "ubuntu-latest"
- or you can add your own runner in self-hosted runners. It can be docker container as well as VM.

When deciding on which to use for your workflow, keep in mind two things:

- Actions you're running on runner, require following tools installed: kubectl, helm, nodejs, yq (list can be extended over time)
- They need to talk. Connectivity from runner machine or container, to target kubernetes cluster is required.

### Adding a self hosted runner to your repository
[GitHub](https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository) outlines the specific actions needed to add a runner to your own repository.


Github workflow may have several jobs, each of them will run on separate runner, selected by tags. For example:

jobs:
  parser:
    runs-on: [self-hosted,dev]

### Build your own container image for runner

Prepare Dockerfile, add all necessary tools (example is - adding gettext package):
```
FROM quay.io/redhat-github-actions/k8s-tools-runner:latest
USER root
RUN dnf -y install gettext && dnf clean all
USER $UID
```
Build image and push to your container registry, example:
```
TOOLS_GHRUNNER_IMAGE=repository.path/cpe/cperunner
TOOLS_GHRUNNER_NAME="${INPUT_CLUSTER}-runner"
STAG=0.0.3
JFROG_USER=xxx
JFROG_TOKEN=zzz

docker build . -t $TOOLS_GHRUNNER_IMAGE:$STAG
docker login -u $JFROG_USER -p $JFROG_TOKEN repository.path
docker push $TOOLS_GHRUNNER_IMAGE:$STAG
```

### Install runner

1. Prepare manifest file runner.yaml for secret and deployment:
```
apiVersion: v1
kind: Secret
metadata:
  name: github-runner
type: Opaque
stringData:
  runner_pat: $GIT_PAT

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: github-runner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: github-runner
  template:
    metadata:
      labels:
        app: github-runner
    spec:
      volumes:
      - name: dockersock
        hostPath:
          path: /var/run/docker.sock
      dnsConfig:
        options:
        - name: ndots
          value: "3"
      imagePullSecrets:
      - name: pullsecret
      containers:
      - name: runner
        image: $TOOLS_GHRUNNER_IMAGE
        resources:
          limits:
            cpu: 725m
            memory: 2Gi
          requests:
            cpu: 150m
            memory: 300Mi
        env:
        - name: ACCESS_TOKEN
          valueFrom:
            secretKeyRef:
              name: github-runner
              key: runner_pat
        - name: LABELS
          value: $TOOLS_GHRUNNER_NAME
        - name: RUNNER_TOKEN
          value: null
        - name: REPO_URL
          value: $TOOLS_GHRUNNER_REPO
        - name: RUNNER_NAME
          value: $TOOLS_GHRUNNER_NAME
        - name: RUNNER_WORKDIR
          value: /tmp
        volumeMounts:
        - name: dockersock
          mountPath: /var/run/docker.sock
```
Replace accordingly:
- `$GIT_PAT` - personal access token for Github
- `$TOOLS_GHRUNNER_IMAGE` - use latest runner image from your repository. For example `repository.path/cpe/cperunner:0.0.1`
- `$TOOLS_GHRUNNER_NAME` - define runner name, `<cluster>-runner`. For example `os-runner` or `gke-runner`

2. Make sure you are logged in to target cluster, can access default namespace using kubectl, then add/update runner deployment:

`$ kubectl apply -f runner.yaml -n default`

!note! You may need to create pull secret in default namespace, and specify it in runner deployment if it's not used by default.

Validate by checking deployment and pod status, pod logs and events.


### Utilize new runner
#### Add runner in repository

Runner should register itself automatically. In repo: settings - actions - runners - see new runner appeared. 
Validate by checking status of runner:

#### Update workflow

In "parser" job where we setup variables per target cluster, specify put new tag in "RUNNER" variable, example for gke-runner:
```
"GKE") CLUSTER="gke"
CLUSTER_TYPE="gke"
TOKEN="GCP2_SA_KEY"
GKE_PROJECT="gcpe0002"
GKE_ZONE="us-east1"
RUNNER="[ \"gke-runner\" ]
```
Then "service" job will be using that runner accordingly
```
  service:
    needs: parser
    strategy:
      matrix: ${{ fromJson(needs.parser.outputs.matrix) }}
      fail-fast: false
    runs-on: ${{ fromJson(needs.parser.outputs.runner) }}
```

#### Test new runner

Trigger workflow "deploy service" for target cluster, choose some service with validate command.

See if it completes successfully. Or at least makes it to steps in "service" job, meaning that some actions are performed on new runner.
