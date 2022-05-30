###############################################################################
# Because of changing helm-repo to public redis repository,
# we have to redefine it back 
###############################################################################
helm repo add --force-update helm_repo $OLD_HELM_REPO \
 						--username $OLD_HELM_USER --password $OLD_HELM_PASS
helm repo update

echo Waiting for ges-redis pod being in ready status 
kubectl wait pod --selector app.kubernetes.io/instance=ges-redis \
	--for condition=ready --timeout=180s