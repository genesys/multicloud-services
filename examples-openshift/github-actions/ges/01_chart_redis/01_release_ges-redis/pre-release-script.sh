###############################################################################
# Because of using helm-repo as private repository  in gh-workflow,
# we have to redefine it for installing from public ones 
###############################################################################

# Saving helm_repo parameters before 
export OLD_HELM_REPO=$(helm repo list | grep ^helm_repo | awk '{print $2}')
set -a
eval $(helm env | grep HELM_REPOSITORY_CONFIG)
set +a
export OLD_HELM_USER=$(yq e '.repositories[] | select(.name=="helm_repo") | .username' $HELM_REPOSITORY_CONFIG)
export OLD_HELM_PASS=$(yq e '.repositories[] | select(.name=="helm_repo") | .password' $HELM_REPOSITORY_CONFIG)
echo OLD_HELM_USER: $OLD_HELM_USER

# Then replace helm_repo to bitnami
helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm repo update

###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
# 								Using it! 
# We extract secrets to environment variables. It will evaluate variables in
# override values by workflow.
###############################################################################
function get_secret {
	# Using: get_secret secret_name
	echo $( kubectl get secrets deployment-secrets -o custom-columns=:data.$1 \
			--no-headers | base64 -d )
}

###############################################################################
#       Redis password
###############################################################################
export REDIS_PASSWORD=$( get_secret REDIS_PASSWORD )
###############################################################################