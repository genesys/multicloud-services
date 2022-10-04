## Verify rollout status

kubectl rollout status sts elasticsearch-master --timeout=2m
kubectl rollout status sts elasticsearch-data --timeout=2m
kubectl rollout status sts elasticsearch-ingest --timeout=2m
kubectl rollout status sts elasticsearch-coordinating --timeout=2m
