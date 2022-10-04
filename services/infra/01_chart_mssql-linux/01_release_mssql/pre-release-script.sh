###############################################################################
# Because of using helm-repo as private repository in gh-workflow,
# we have to redefine it for installing from public repo 
###############################################################################
helm repo add --force-update helm_repo https://charts.helm.sh/stable
helm repo update

[[ "$CLUSTER_TYPE" == "openshift" ]] && \
    oc adm policy add-scc-to-user anyuid -z default -n $NS

return 0