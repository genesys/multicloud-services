###############################################################################
# 				Health check UCSX
# 
# We need to ensure that UCSX is properly running before next chart
# deployment (provisioning chart)
###############################################################################

echo "##################### 2. Validate that all pods have status running"
for i in {1..12}; do
  echo "waiting for pods to get running.." && sleep 5
  CSTAT=$(oc get pods -l service=ucsx,tenant=shared  --no-headers | awk '{print $3}' | sort | uniq)
  [[ $CSTAT == "Running" ]] && break
  [[ $i == 12 ]] && echo "ERROR: can't get pods in running status" && exit 1
done
echo "successfully got all pods in running status"

echo "##################### 3. Quick Healthcheck"
for pod in $(oc get pods -l service=ucsx,tenant=shared  --no-headers | grep Running | awk '{print $1}'); do
  echo "healthcheck for $pod"
  for i in {1..12}; do
    echo "waiting.." && sleep 5
    db_health=$(kubectl exec $pod -- curl -skL localhost:10052/metrics | grep ucsx_masterdb_health_status{ | cut -d' ' -f 2)
    es_health=$(kubectl exec $pod -- curl -skL localhost:10052/metrics | grep ucsx_elasticsearch_health_status{ | cut -d' ' -f 2)

    [[ $db_health == "1" && $es_health == "1" ]] && break
    [[ $i == 12 ]] && echo "ERROR: $pod is not healthy" && exit 1
  done
  echo "$pod is healthy"
done