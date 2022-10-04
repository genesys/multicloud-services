###############################################################################
# Wait for all pods to be ready
###############################################################################
kubectl rollout status sts infra-redis-redis-cluster --timeout=4m