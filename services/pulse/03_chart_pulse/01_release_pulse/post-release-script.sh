###############################################################################
# Helper functions
###############################################################################

function check_pulse_health {
  #############################################
  # Using: check_pulse_health time_limit
  #############################################
    time_limit=$1
    n=$(expr $time_limit / 5)
    echo "Validating Pulse health status "
    kubectl -n $NS port-forward svc/pulse 8090:8090 >>/dev/null 2>&1 &
    for i in $(seq 1 $n); do
      echo "$i waiting Pulse health status ..." && sleep 5
      res=$(curl -s -X GET http://127.0.0.1:8090/actuator/metrics/pulse.health.all | \
        jq '.measurements[] | select(.statistic|test("VALUE")) | .value')
      echo "Pulse health status: res=$res"
      [[ "$res" == "1" ]] || [[ "$res" == "1.0" ]]  && break
      [[ $i == $n ]] && echo "ERROR: pulse is unhealthy" && kill %1 && exit 1
    done
    kill %1
    echo "Pulse is healthy!"
}
###############################################################################


wait_running_status servicename=pulse 3000

check_pulse_health 1200