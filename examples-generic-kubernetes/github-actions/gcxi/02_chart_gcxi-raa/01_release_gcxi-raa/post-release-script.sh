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
( ! wait_running_status "servicename=gcxi-raa" 300 ) && exit 1
###############################################################################
# Health-check
###############################################################################
#may take 10 min for gcxi pods to get ready and respond via Http
for i in {1..40}; do
  echo "waiting for Http healthcheck response.." && sleep 15
  HSTAT=$(curl -ks https://web-gcxi.${DOMAIN}/gcxi/monitor/metrics| grep gcxi__projects__status| cut -d' ' -f2| rev)
  [[ "$HSTAT" == "0" ]] && break
  [[ $i == 40 ]] && echo "ERROR: GCXI health check failed" && exit 1
done
echo "GCXI health check is successful"
