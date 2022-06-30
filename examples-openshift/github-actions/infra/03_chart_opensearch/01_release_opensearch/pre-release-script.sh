###############################################################################
# Because of using helm-repo as private repository  in gh-workflow,
# we have to redefine it for installing from public ones 
###############################################################################
helm repo add --force-update helm_repo https://opensearch-project.github.io/helm-charts/
helm repo update