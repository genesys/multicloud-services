###############################################################################
# Validate that all pods have status running
###############################################################################
( ! wait_running_status "servicename=gcxi-raa" 300 ) && exit 1

###############################################################################
# Health-check
###############################################################################
#may take 10 min for gcxi pods to get ready and respond via Http
print_log "GCXI health check start"
for i in {1..40}; do
  echo "waiting for Http healthcheck response.." && sleep 15
  # Direct request from GHA runner to external ingress may be problematic due to connectivity
  #HSTAT=$(curl -ks https://web-gcxi-${TENANT_SID}.${DOMAIN}/gcxi/monitor/metrics| grep gcxi__projects__status| cut -d' ' -f2| rev)
  # Trying internal request from within RAA pod
  HSTAT=$(kubectl exec gcxi-raa-statefulset-0 -c gcxi-raa -- bash -c "curl -s gcxi-${TENANT_SID}:8180/gcxi/monitor/metrics" | \
    grep gcxi__projects__status | cut -d' ' -f2| rev)
  echo "healthcheck result: $HSTAT"
  [[ "$HSTAT" == "0" ]] && break
  [[ $i == 40 ]] && error_exit "GCXI health check failed"
done
print_log "GCXI health check is successful"