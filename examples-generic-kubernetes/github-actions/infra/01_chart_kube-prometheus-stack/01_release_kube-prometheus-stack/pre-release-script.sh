# Prometheus operator
# Use in GKE and generic k8s (Openshift has its own monitoring stack)
# https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

helm repo add --force-update helm_repo https://prometheus-community.github.io/helm-charts
helm repo update


# May need to update prometheus to auto-discover in all namespaces:
# $ kubectl edit prometheus prometheus-stack-kube-prom-prometheus
# spec:
#   serviceMonitorNamespaceSelector: {}
#   serviceMonitorSelector: {}

# Grafana: admin / prom-operator
