## Check pod status

kubectl rollout status deploy ixn-${TENANT_SID}-vqnode-deploy --timeout=2m
kubectl rollout status sts ixn-${TENANT_SID}-sts --timeout=4m