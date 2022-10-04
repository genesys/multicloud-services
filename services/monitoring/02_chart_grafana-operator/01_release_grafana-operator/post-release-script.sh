# Add prometheus datasource
kubectl apply -f grafana-datasource-prometheus.yaml

# Check pod status
kubectl rollout status deploy grafana-operator --timeout=2m
kubectl rollout status deploy grafana-deployment --timeout=2m

print_log "Grafana operator is successfully installed"
print_log "Web UI login: https://grafana.$DOMAIN"
print_log "you can find login credentials in secret \"grafana-admin-credentials\""