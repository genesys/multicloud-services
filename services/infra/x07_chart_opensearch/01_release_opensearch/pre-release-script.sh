###############################################################################
# Because of using private helm repository in gh-workflow,
# we have to redefine it to certain public repository 
###############################################################################
helm repo add --force-update helm_repo https://opensearch-project.github.io/helm-charts/
helm repo update

[[ "$CLUSTER_TYPE" == "openshift" ]] && export STORAGE_CLASS_RWO_PREMIUM=infra-storage

return 0