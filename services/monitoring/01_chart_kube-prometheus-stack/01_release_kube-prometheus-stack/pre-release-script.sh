# Prometheus operator
# Use in GKE and generic k8s (Openshift has its own monitoring stack)
# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

helm repo add --force-update helm_repo https://prometheus-community.github.io/helm-charts
helm_repo_update

# if [ "$CLUSTER_TYPE" == "openshift" ]; then
#     # node exporter requires hostPath access
#     #oc adm policy add-scc-to-user hostmount-anyuid -z kube-prometheus-stack-prometheus-node-exporter -n $NS
#     envsubst < scc_prom_permissions.yaml | oc apply -f -
# fi