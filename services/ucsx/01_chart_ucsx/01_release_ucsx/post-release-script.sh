###############################################################################
# Health check UCSX
# We need to ensure that UCSX is properly running before next chart
# deployment (provisioning chart)
###############################################################################

print_log "Validate that all pods have status running"
wait_running_status "service=ucsx,tenant=shared" 180
print_log "successfully got all pods in running status"

print_log "Quick Healthcheck"
for pod in $(oc get pods -l service=ucsx,tenant=shared  --no-headers | grep Running | awk '{print $1}'); do
  print_log "healthcheck for $pod"
  for i in {1..12}; do
    echo "waiting.." && sleep 5
    db_health=$(kubectl exec $pod -- curl -skL localhost:10052/metrics | grep ucsx_masterdb_health_status{ | cut -d' ' -f 2)
    es_health=$(kubectl exec $pod -- curl -skL localhost:10052/metrics | grep ucsx_elasticsearch_health_status{ | cut -d' ' -f 2)

    [[ $db_health == "1" && $es_health == "1" ]] && break
    [[ $i == 12 ]] && error_exit "ERROR: $pod is not healthy"
  done
  print_log "$pod is healthy"
done