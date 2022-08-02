# Loki stack from Grafana: https://grafana.com/docs/loki/latest/
# Installs Loki + Promtail

helm repo add --force-update helm_repo https://grafana.github.io/helm-charts
helm repo update

echo "Creating loki-config secrets with configuration"
kubectl create secret generic loki-config --from-file=loki.yaml=loki-config.yaml --dry-run=client -o yaml | kubectl apply -f -
