#############################################################################
# Helper functions
#############################################################################
function wait_running_status {
  #############################################
  # Using: wait_running_status pod-labels time_limit
  #############################################
    labels=$1; pod_status="Running"; time_limit=$2
    n=$(expr $time_limit / 5)
    echo "Validate pods with labels <$labels> have status <$pod_status>"
    for i in $(seq 1 $n); do
      echo "${i}) waiting for pods to get status $pod_status ..." && sleep 5
      kubectl get pods -l $labels --no-headers 
      PSTAT=$(kubectl get pods -l $labels --no-headers | awk '{print $3}' | sort | uniq)
      if [[ "$PSTAT" == "$pod_status" ]]; then
          echo "Checking all of containers is running..."
          s=$(kubectl get pods -l $labels --no-headers | awk '{print $2}' | sort | uniq)
          echo "Containers STATUS: $s"
          c_run=$(echo $s | sed 's/\/.*//')
          c_plan=$(echo $s | sed 's/.*\///')
          [[ "$c_run" == "$c_plan" ]] && break
      fi
      [[ $i == $n ]] && echo "ERROR: can't get pods in status: $pod_status" && return 1
    done
    echo "Pods with <$labels> in <$pod_status> status!"
}

###############################################################################


###############################################################################
# Validate that all pods have status running
###############################################################################
( ! wait_running_status "service=cxc" 600 ) && exit 1

if [ $(oc get route | grep cxc-amark | grep edge | wc -l) != 2 ]; then
  echo "Routes do not exist, creating them"
  oc create route edge --service=cxc-amark-app --hostname=cxc.$DOMAIN --path /cx-contact/ --port=http || true
  oc create route edge --service=cxc-amark-ui  --hostname=cxc.$DOMAIN --path /ui/cxcontact/ --port=http || true
  oc annotate route cxc-amark-app router.openshift.io/cookie_name=cxc-session-cookie
  oc annotate route cxc-amark-ui  router.openshift.io/cookie_name=cxc-session-cookie
else
  echo "Edge Routes Already exist"
fi

echo "Post-realease actions are done!"