## Latest Elasticsearch + Kibana from Bitnami
## https://docs.bitnami.com/tutorials/integrate-logging-kubernetes-kibana-elasticsearch-fluentd/

helm repo add --force-update helm_repo https://charts.bitnami.com/bitnami
helm repo update

[[ "$CLUSTER_TYPE" == "openshift" ]] && export STORAGE_CLASS_RWO_PREMIUM=logging-storage

return 0