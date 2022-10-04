#############################################################################
# TENANT PROVISIONING
# https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide/EnableTenant
#############################################################################


###############################################################################
# Validate that all pods have status running
###############################################################################
( ! wait_running_status "servicename=iwd" 300 ) && exit 1

###############################################################################
# Creating routes for Openshift
###############################################################################

if [ "$CLUSTER_TYPE" == "openshift" ]; then
  print_log "check Openshift Routes"
  if ! oc get route | grep iwd  ; then
    print_log "routes do not exist creating them"
    oc create route edge --service=iwd --hostname=iwd.$DOMAIN --path / --port=web
  else
    print_log "IWD Routes Already exist"
  fi
fi



#############################################################################
#  Defining: IWD_PROVISION_PARAMS
#############################################################################
function IWD_PROVISION_PARAMS {
  cat <<EOF
{
  "tenant": {
    "id": "$TENANT_SID",
    "name": "t${TENANT_SID}",
    "ccid": "$TENANT_UUID",
    "apiKey": "${iwd_tenant_api_key}",
    "gws": {
      "gwsUrl": "http://gws-service-proxy.gws",
       "data": {
       "authUrl": "http://gauth-auth.gauth",
       "authredircetUrl": "https://gauth.${DOMAIN}" 
       },
       "secret": {
          "clientId": "${iwd_gws_client_id}", 
          "clientSecret": "${iwd_gws_client_secret}",
          "apikey": "none",  
          "username": "default",
          "token": "password" 
            }
        }
  },
  "iwd": {
    "url": "http://iwd.${NS}:4024",
    "db": {
      "host": "$POSTGRES_ADDR",
      "port": 5432,
      "database": "${iwd_db_name}",
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
# Creating provisioning request using API
#
# You can use direct curl request to "https://iwd.${DOMAIN}/iwd/v3/provisioning"
# if external ingress is accessible from GHA runner.
# If not accessible, we do it from inside the cluster
#############################################################################
kubectl run curlbox --image=alpine/curl --restart=Never -- \
  curl "http://iwd.${NS}:4024/iwd/v3/provisioning" \
  -H "Content-Type: application/json; charset=utf-8" \
  -H "x-api-key: ${iwd_tenant_api_key}" \
  -d "$(IWD_PROVISION_PARAMS)"
sleep 30
kubectl logs curlbox
kubectl delete pods curlbox
