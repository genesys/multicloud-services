###############################################################################
# Validate that all pods have status running
###############################################################################
( ! wait_running_status "servicename=gcxi" 1800 ) && exit 1

print_log "GCXI pods are in running status!"
###############################################################################


###############################################################################
# Creating route
###############################################################################
if [ "$CLUSTER_TYPE" == "openshift" ]; then
  print_log "check Openshift Routes"
  if ! oc get route | grep gcxi | grep edge ; then
    print_log "routes do not exist creating them"
    oc create route edge --service=gcxi --hostname=web-gcxi-${TENANT_SID}.$DOMAIN --path / --port=web
  else
    print_log "GCXI Routes Already exist"
  fi
fi