###############################################################################
# Because of using helm-repo as private repository  in gh-workflow,
# we have to reddefine it for installing from public ones 
###############################################################################
helm repo add --force-update helm_repo https://charts.helm.sh/stable
helm repo update