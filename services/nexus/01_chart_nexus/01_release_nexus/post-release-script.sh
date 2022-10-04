# wait for readiness
wait_running_status "servicename=nexus" 300

#############################################################################
#  TENANT PROVISIONING
#  https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide/EnableTenant
#############################################################################

print_log "check if Nexus provisioning is required for tenant $TENANT_SID"

if kubectl get pod nexus-tenant-$TENANT_SID >/dev/null 2>&1; then
    print_log "found pod nexus-tenant-$TENANT_SID, looks like Nexus was already provisioned for tenant $TENANT_SID"
    print_log "to enforce provisioning, please delete this pod and re-run pipeline"
    print_log "exiting Nexus provisioning"
    return 0
fi

#############################################################################
platform="Azure"
location=$LOCATION
locations=${nexus_tenant_locations:-"$location"}  #can be comma-separated list

tenant_dep_version="100.0.127.4797" #"9.0.000.01.0000" # prototype version - to be replaced to latest once released

function restart_nexus {
  #############################################
  #  Using: restart_nexus
  #############################################
  nex_depl=$(kubectl get deployment | grep -e 'nexus-[0-9]' | awk '{print $1}')
  kubectl rollout restart deployment $nex_depl
  sleep 20
  wait_running_status "servicename=nexus" 300
}

#############################################################################
#  Workaround for nexus/nex_gapis table issue.
#  At the 1st start of nexus container doesn`t add additinal columns region, authinturl, authtexturl
#############################################################################
restart_nexus

#############################################################################
#  Add GWS to the nex_gapis table in nexus database
#  https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide/EnableTenant#Add_GWS_to_the_nex_gapis_table_for_Nexus
#############################################################################
kubectl delete pod nexus-db-configurator >/dev/null 2>&1 || true
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

kubectl run nexus-db-configurator --image=postgres --env=PGUSER=${nexus_db_user} \
  --env=PGPASSWORD=${nexus_db_password} --labels="servicename=tenant-provisioning" \
  --restart='Never' --command -- sh -c "
                    psql -h $POSTGRES_ADDR -d nexus -tc \"$rq1\"
                    psql -h $POSTGRES_ADDR -d nexus -tc \"$rq2\"
                    psql -h $POSTGRES_ADDR -d nexus -tc \"$rq3\"
                    "
echo "Run <kubectl logs nexus-db-configurator> to list nexus apikeys" 

restart_nexus

#############################################################################
#  Creating secret: nexus-new-tenant-credentials
#############################################################################
cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: nexus-new-tenant-credentials
type: Opaque
stringData:
  credentials: |
    {
      "cmeUser": "$nexus_tenant_adm_user",
      "cmePassword": "$nexus_tenant_adm_pass",
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
    "folderForObjects": "t$TENANT_SID",
    "host1": "tenant-$TENANT_UUID.$VOICE_NAMESPACE",
    "host2": "tenant-$TENANT_UUID.$VOICE_NAMESPACE"
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
    "ccid": "$TENANT_UUID",
    "id": "$TENANT_SID",
    "name": "t$TENANT_SID",
    "region": "$location"
  }
}
EOF
  )

print_log "NEXUS_PROVISION_PARAMS:"
echo $NEXUS_PROVISION_PARAMS
NEXUS_PROVISION_PARAMS=$(echo $NEXUS_PROVISION_PARAMS | jq -c)

#############################################################################
#  Creating provisioning POD
#############################################################################
cat <<EOF | envsubst | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: "nexus-tenant-$TENANT_SID"
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

print_log "Nexus provisioning for tenant $TENANT_SID is triggered"
print_log "check logs of pod nexus-tenant-$TENANT_SID"