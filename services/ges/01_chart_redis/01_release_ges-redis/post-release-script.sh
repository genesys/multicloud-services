print_log "waiting for ges-redis pod to obtain ready status"
kubectl wait pod --selector app.kubernetes.io/instance=ges-redis \
	--for condition=ready --timeout=180s

###############################################################################
# Back to using our private registry
###############################################################################
print_log "Helm repo restore"
helm repo add --force-update helm_repo $OLD_HELM_REPO \
    --username "$HELM_REGISTRY_USER" --password "$HELM_REGISTRY_TOKEN"
helm repo update
