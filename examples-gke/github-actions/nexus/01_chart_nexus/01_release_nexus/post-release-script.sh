#############################################################################
#                         TENANT PROVISIONING
#
# https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide/EnableTenant
#############################################################################

GAUTH_NAMESPACE=gauth
GWS_NAMESPACE=gws
VOICE_NAMESPACE=voice
UCSX_NAMESPACE=ucsx
platform="Azure"
location=${tenant_primary_location:-"USW1"}
locations=${tenant_locations:-"westus2"}
tenant_dep_version="9.0.000.01.0000" # prototype version - to be replaced to latest once released

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

function restart_nexus {
  #############################################
  # Using: restart_nexus
  #############################################
  nex_depl=$(kubectl get deployment | grep -e 'nexus-[0-9]' | awk '{print $1}')
  kubectl scale deployment $nex_depl --replicas=0 || true
  sleep 20
  kubectl scale deployment $nex_depl --replicas=1 || true
  wait_running_status "servicename=nexus" 300
}
###############################################################################


wait_running_status "servicename=nexus" 300

#############################################################################
#     nexus/nex_gapis table issue
# 
# at the 1st start of nexus container doesn`t add additinal columns region, 
# authinturl, authtexturl
#############################################################################
restart_nexus


#############################################################################
# Add GWS to the nex_gapis table in nexus database
#
# https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide/EnableTenant#Add_GWS_to_the_nex_gapis_table_for_Nexus
#############################################################################
if ( ! kubectl get pods nexus-db-configurator --no-headers >>/dev/null 2>&1 );then
  rq1="INSERT INTO nex_gapis \
    (url, clientid, apikey, clientsecret, created, authinturl, authexturl) VALUES \
    ('http://gws-service-proxy.${GWS_NAMESPACE}', '${nexus_gws_client_id}', \
    'NA', '${nexus_gws_client_secret}', now(),
    'http://gauth-auth.${GAUTH_NAMESPACE}','https://gauth.${DOMAIN}')"
  rq2="INSERT INTO nex_gapis \
    (url, clientid, apikey, clientsecret, created, authinturl, authexturl) VALUES \
    ('http://gauth-auth.${GAUTH_NAMESPACE}', '${nexus_gws_client_id}', \
    'NA', '${nexus_gws_client_secret}', now(),
    'http://gauth-auth.${GAUTH_NAMESPACE}','https://gauth.${DOMAIN}')"
  rq3="SELECT name,id FROM nex_apikeys"
  kubectl run  nexus-db-configurator --image=postgres --env=PGUSER=${nexus_db_user} \
    --env=PGPASSWORD=${nexus_db_password} --labels="servicename=tenant-provisioning" \
    --restart='Never' --command -- sh -c "
                      psql -h $POSTGRES_ADDR -d nexus -tc \"$rq1\"
                      psql -h $POSTGRES_ADDR -d nexus -tc \"$rq2\"
                      psql -h $POSTGRES_ADDR -d nexus -tc \"$rq3\"
                      "
    echo "Run <kubectl logs nexus-db-configurator> to list nexus apikeys" 
fi

restart_nexus

#############################################################################
#  Creating secret: nexus-new-tenant-credentials
#############################################################################
cat <<EOF | envsubst | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: nexus-new-tenant-credentials
type: Opaque
stringData:
  credentials: |
    {
      "cmeUser": "default",
      "cmePassword": "password",
      "gwsClientId": "$nexus_gws_client_id",
      "gwsSecret": "$nexus_gws_client_secret"
    }
EOF

#############################################################################
#  Defining: NEXUS_PROVISION_PARAMS
#############################################################################
NEXUS_PROVISION_PARAMS=$(cat <<EOF
{
  "debug": true,
  "cme": {
    "folderForObjects": "t$tenant_sid",
    "host1": "tenant-$tenant_id.$VOICE_NAMESPACE",
    "host2": "tenant-$tenant_id.$VOICE_NAMESPACE"
  },
  "gws": {
    "client_id": "$nexus_gws_client_id",
    "client_secret": "$nexus_gws_client_secret",
    "extUrl": "http://gws-service-proxy.$GWS_NAMESPACE",
    "intUrl": "http://gws-service-proxy.$GWS_NAMESPACE",
    "authUrl": "http://gauth-auth.$GAUTH_NAMESPACE",
    "envUrl": "http://gauth-environment.$GAUTH_NAMESPACE"
  },
  "ucs": {
    "url": "http://ucsx.${UCSX_NAMESPACE}:8080"
  },
  "nexus": {
    "region": "$location",
    "url": "http://nexus.$NS",
    "urlFromEsv": "http://nexus.$NS"
  },
  "platform": "$platform",
  "tenant": {
    "allRegions": ["$locations"],
    "ccid": "$tenant_id",
    "id": "$tenant_sid",
    "name": "t$tenant_sid",
    "region": "$location"
  }
}
EOF
  )
echo "NEXUS_PROVISION_PARAMS:"
echo $NEXUS_PROVISION_PARAMS
NEXUS_PROVISION_PARAMS=$(echo $NEXUS_PROVISION_PARAMS | jq -c)

#############################################################################
#  Creating provisioning POD
#############################################################################
cat <<EOF | envsubst | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: "nexus-tenant-$tenant_sid"
  labels:
    service: nexus
    servicename: tenant-provisioning
spec:
  containers:
    - env:
        - name: NEXUS_PROVISION_PARAMS
          value: |-
            $NEXUS_PROVISION_PARAMS
        - name: ENVIRONMENT_TYPE
          value: azure
      image: "$IMAGE_REGISTRY/nexus/tenant_deployment:$tenant_dep_version"
      imagePullPolicy: Always
      name: tenant-deployment
      resources: {}
      terminationMessagePath: /dev/termination-log
      terminationMessagePolicy: File
      volumeMounts:
        - mountPath: /tenant
          name: credentials
          readOnly: true
  dnsPolicy: ClusterFirst
  restartPolicy: Never
  schedulerName: default-scheduler
  securityContext: {}
  terminationGracePeriodSeconds: 30
  imagePullSecrets:
    - name: pullsecret
  volumes:
    - name: credentials
      secret:
        defaultMode: 440
        secretName: nexus-new-tenant-credentials
EOF