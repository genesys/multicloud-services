# Check pod status

kubectl rollout status deploy kube-prometheus-stack-operator --timeout=4m
#kubectl rollout status ds kube-prometheus-stack-prometheus-node-exporter --timeout=4m
