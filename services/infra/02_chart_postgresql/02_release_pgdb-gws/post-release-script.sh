############################################
# Wait for readiness
kubectl rollout status sts $RELEASE-postgresql

# Post installation performance benchmarking
pg_benchmark