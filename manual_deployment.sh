# This script emulates CD pipeline
# Run deployment from local machine
# Can be useful to debug, or if Github is having issues, runners are unavailable,
# or simply to speed up deployment process.

# Steps:
# 1) log in to target kubernetes cluster
#    (❗ IMPORTANT) this script will NOT log you in to cluster and setup your kube context.
# 2) some services require deployment-secrets to be manually added prior to deployment, create it if not present
#    you can check existing secrets for example by:
#    $ kubectl get secret deployment-secrets -o json | jq '.data | map_values(@base64d)'
# 3) adjust INPUT parameters (avoid adding sensitive information in script, see recommendations below)
# 4) then run the script: ./manual_deployment.sh

###################################################################################################
#  INPUT
###################################################################################################

export CLUSTER=aro1                  #target cluster
export CLUSTER_TYPE=openshift        #cluster type: [openshift, gke, aks, k8s]
export SERVICE=gws
export NS=                           #target namespace, empty for default
export FULLCOMMAND="install"


# Your private registries info
# provide these parameters via env variables, and NOT(‼️) here in script
# example: export HELM_REGISTRY_USER=xxxx
[[ ! "$HELM_REGISTRY_USER" ]]   && echo "need registry creds" && exit 1 
[[ ! "$HELM_REGISTRY_TOKEN" ]]  && echo "need registry creds" && exit 1
[[ ! "$IMAGE_REGISTRY_USER" ]]  && echo "need registry creds" && exit 1
[[ ! "$IMAGE_REGISTRY_TOKEN" ]] && echo "need registry creds" && exit 1

# set in your command line shell (before running the script) like:
#   export HELM_REGISTRY=https://yourcompany.jfrog.io/artifactory/
#   export IMAGE_REGISTRY=yourcompany-docker-staging.jfrog.io
[[ ! "$HELM_REGISTRY" ]]  && echo "need helm registry address" && exit 1
[[ ! "$IMAGE_REGISTRY" ]] && echo "need container image registry address" && exit 1

[[ ! "$HELM_REPO_NAME" ]] && export HELM_REPO_NAME=helm-stage


###################################################################################################
#  HELPER FUNCTIONS
###################################################################################################
create_pull_secret() {
    if ! kubectl get secret pullsecret ; then
        kubectl create secret docker-registry pullsecret \
        --docker-server=$IMAGE_REGISTRY \
        --docker-username=$IMAGE_REGISTRY_USER --docker-password=$IMAGE_REGISTRY_TOKEN
        [[ "$CLUSTER_TYPE" == "openshift" ]] && oc secrets link default pullsecret --for=pull
        echo "Default pullsecret created"
    else
        echo "Default pullsecret already present"
    fi
}

###################################################################################################
#  PREPARE ENVIRONMENT
###################################################################################################

set -e

cd "$(dirname "$0")"

helm repo add --force-update helm_repo ${HELM_REGISTRY}${HELM_REPO_NAME} \
    --username $HELM_REGISTRY_USER --password $HELM_REGISTRY_TOKEN

if [ -z "$NS" ]; then
    [[ "$SERVICE" == "tenant" ]] && NS=voice || NS=$SERVICE
fi

if ! kubectl get namespace $NS; then
    echo "Namespace $NS does not exist. Creating it.."
    kubectl create namespace $NS
fi

kubectl config set-context --current --namespace=$NS

create_pull_secret

###################################################################################################
#  RUN THE DEPLOYMENT
###################################################################################################

COMMAND=$(echo $FULLCOMMAND | cut -d' ' -f1)
if [[ "$FULLCOMMAND" == *" "* ]]; then
    CHART_NAME=$(echo $FULLCOMMAND | tr -s ' ' | cut -d' ' -f2)
    RL_NAME=$(echo $FULLCOMMAND | tr -s ' ' | cut -d' ' -f3)
fi

cd services/$SERVICE

source ../deployment.sh
