###############################################################################
# Saving helm_repo parameters, to restore after Redis deployment
###############################################################################
OLD_HELM_REPO=$(helm repo list | grep ^helm_repo\\s | awk '{print $2}')

###############################################################################
# Because of using helm-repo as private repository in gh-workflow,
# we have to redefine it for installing from public ones 
###############################################################################
helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm_repo_update