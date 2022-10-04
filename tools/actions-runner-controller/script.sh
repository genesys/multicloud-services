#!/bin/bash

########################################################################################
# Pre-requisite:
# 
# 1) Before running the script.sh, provide your personal access token by
#    export GITHUB_TOKEN=...

[[ ! "$GITHUB_TOKEN" ]] && error_exit "Need GITHUB_TOKEN in your deployment secrets"

# 2) You need to have pull secret "pullsecret" in 
#    deployment namespace, to allow pulling container image from your private repository
#    kubectl create secret docker-registry pullsecret --docker-server=<your_docker_registry> --docker-username=.. --docker-password=..

# 3) Provide your private docker repo + image name, if necessary. Below is an example.

[[ ! "$STAG" ]] && STAG=latest
[[ ! "$RUNNER_IMAGE" ]] && export RUNNER_IMAGE=pureengage-docker-staging.jfrog.io/cpe/arc-runner

########################################################################################

# Add helm repository
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller

# Auth secret (using PAT)
kubectl create secret generic controller-manager \
    --from-literal=github_token=${GITHUB_TOKEN}

# Install controller
helm upgrade --install --wait \
    actions-runner-controller actions-runner-controller/actions-runner-controller


########################################################################################
# Helper function
function add_runner {
  # Add runner per-repository
  # usage:    add_runner <repo_name> <labels>
  # example:  add_runner cpe-service-deploy vce-runner
  #           add_runner cpe-service-deploy vce-runner,inventory-runner
cat <<EOF | kubectl apply -f -
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: runner-$1
spec:
  replicas: 1
  template:
    spec:
      repository: genesysengage/$1
      labels: [ $2 ]
      image: $RUNNER_IMAGE:$STAG
      imagePullSecrets:
        - name: pullsecret
EOF

# ## Extras: can add "HorizontalRunnerAutoscaler" for automated scaling
# cat <<EOF | kubectl apply -f -
# apiVersion: actions.summerwind.dev/v1alpha1
# kind: HorizontalRunnerAutoscaler
# metadata:
#   name: runner-$1-autoscaler
# spec:
#   scaleTargetRef:
#     kind: RunnerDeployment
#     name: runner-$1
#   minReplicas: 1
#   maxReplicas: 3
#   metrics:
#   - type: PercentageRunnersBusy
#     scaleUpThreshold: '0.75'    # The percentage of busy runners at which the number of desired runners are re-evaluated to scale up
#     scaleDownThreshold: '0.3'   # The percentage of busy runners at which the number of desired runners are re-evaluated to scale down
#     scaleUpFactor: '1.4'        # The scale up multiplier factor applied to desired count
#     scaleDownFactor: '0.7'      # The scale down multiplier factor applied to desired count
# EOF
}
########################################################################################


# Now add CRD "RunnerDeployment" for particular repositories
# Then your runner will start and register to repository,
# with specific label $CLUSTER-runner (update for your needs)

add_runner cpe-service-deploy $CLUSTER-runner
add_runner multicloud-services $CLUSTER-runner
sleep 10

############################
print_log "Verification:"
kubectl get RunnerDeployment
kubectl get runner

# Check logs of runner
print_log "Runner log:"
kubectl logs $(k get po --no-headers| grep -m1 ^runner- | awk '{print $1}')