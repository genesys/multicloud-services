###############################################################################
# Because of using helm-repo as private repository  in gh-workflow,
# we have to reddefine it for installing from public ones 
###############################################################################
helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm repo update

# For upgrade purposes we need to use existing redis password
if [[ "$(kubectl get -n $NS secrets infra-redis-redis-cluster -o jsonpath='{.data.redis-password}')" ]]; then
	cat << EOF  >> override_values.yaml

password: "$(kubectl get -n $NS secrets infra-redis-redis-cluster -o jsonpath='{.data.redis-password}' | base64 -d)"
EOF
fi