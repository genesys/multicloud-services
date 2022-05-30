#############################################################################
#                         TENANT PROVISIONING
#
# https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide/EnableTenant
#############################################################################


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
( ! wait_running_status "servicename=iwd" 300 ) && exit 1

#############################################################################
#  Defining: IWD_PROVISION_PARAMS
#############################################################################
function IWD_PROVISION_PARAMS {
  cat <<EOF
{
  "tenant": {
    "id": "$tenant_sid",
    "name": "t${tenant_sid}",
    "ccid": "$tenant_id",
    "apiKey": "${iwd_tenant_api_key}"
  },
  "iwd": {
    "url": "http://iwd.${NS}:4024",
    "db": {
      "host": "$POSTGRES_ADDR",
      "port": 5432,
      "database": "iwd-${tenant_sid}",
      "user": "${iwd_db_user}",
      "password": "${iwd_db_password}",
      "ssl": false
    },
    "apiKeys": {
      "IWD_APIKEY_TENANT": "${iwd_tenant_api_key_tenant}",
      "IWD_APIKEY_IWDDM": "${iwd_tenant_api_key_iwddm}"
    }
  },
  "iwdEmail": {
    "url": "N/A"
  }
}
EOF
}
echo "IWD_PROVISION_PARAMS:"
echo $(IWD_PROVISION_PARAMS) | jq

#############################################################################
#  Creating provisioning request using API
#
# Use direct curl request to "http://iwd.${DOMAIN}/iwd/v3/provisioning" if 
# it`s possible.
# But by some reasons dns or ingress cann`t work properly, so use special
# curl pod that do it using internal connections 
#############################################################################
kubectl run curlbox --image=alpine/curl --restart=Never -- \
  curl "http://iwd.${NS}:4024/iwd/v3/provisioning" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "x-api-key: ${iwd_tenant_api_key}" \
  -d "$(IWD_PROVISION_PARAMS)"
sleep 30
kubectl logs curlbox
kubectl delete pods curlbox