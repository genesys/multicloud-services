######## Optional variables with defaults

# if not provided in deployment secrets
if [ ! "$ges_redis_password" ]; then
    if kubectl get secrets ges-redis >> /dev/null 2>&1
    then
        # take from redis secret
        export ges_redis_password=$(kubectl get secrets ges-redis -o jsonpath='{.data.redis-password}' | base64 -d)
    else
        # otherwise take from global default $REDIS_PASSWORD, or generate randomly
        export ges_redis_password=${REDIS_PASSWORD:=$(head /dev/urandom | LC_CTYPE=C tr -cd '[:alnum:]' | head -c 15)}
    fi 
fi


###############################################################################
# Saving helm_repo parameters, to restore after Redis deployment
###############################################################################
OLD_HELM_REPO=$(helm repo list | grep ^helm_repo | awk '{print $2}')

###############################################################################
# Because of using helm-repo as private repository in gh-workflow,
# we have to redefine it for installing from public ones 
###############################################################################
helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm_repo_update