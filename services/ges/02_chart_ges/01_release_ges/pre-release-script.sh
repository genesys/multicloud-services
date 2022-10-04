########### Mandatory variables

[[ ! "$ges_gws_client_secret" ]] && error_exit "need GES auth client secret, provided via deployment secrets"

########### Optional variables with defaults
[[ ! "$POSTGRES_STD_ADDR" ]] && export POSTGRES_ADDR="$POSTGRES_STD_ADDR"

[[ ! "$ges_gws_client_id" ]] && export ges_gws_client_id="$auth_client_ges"
[[ ! "$ges_db_name" ]] && export ges_db_name=ges
[[ ! "$ges_db_user" ]] && export ges_db_user=ges
[[ ! "$ges_db_password" ]] && export ges_db_password=ges

[[ ! "$ges_devops_username" ]] && export ges_devops_username=admin
[[ ! "$ges_devops_password" ]] && export ges_devops_password=letmein

###############################################################################
# ORS steam Redis
if [ ! "$ges_redis_ors_host" ] && [ ! "$ges_redis_ors_password" ]
then
    # typically it's infra Redis, same as redis-ors-stream.voice.svc.cluster.local
    #export ges_redis_ors_host=redis-ors-stream.service.${CONSUL_DC_LOCATION}.consul    #resolving via consul
    export ges_redis_ors_host=redis-ors-stream.${VOICE_NAMESPACE}.svc.${DNS_SCOPE}    #directly pointing to voice ns

    # fetching Redis password from voice namespace secret
    ro_scr=$(kubectl get secret redis-config-token -n $VOICE_NAMESPACE -o jsonpath={.data.redis-config-state})
    [[ ! "$ro_scr" ]] && error_exit "Voice must be installed already"
    export ges_redis_ors_password=$(echo $ro_scr | base64 -d | jq -r .password)
fi

###############################################################################
# Creating secrets
###############################################################################
kubectl create secret generic ges-secrets-infra \
  --from-literal=DB-USER=$ges_db_user \
  --from-literal=DB-PASSWORD=$ges_db_password \
  --from-literal=REDIS_CACHEKEY=$ges_redis_password \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic gws-client-credentials \
  --from-literal=AUTHENTICATION-CLIENT-ID=$ges_gws_client_id \
  --from-literal=AUTHENTICATION-CLIENT-SECRET=$ges_gws_client_secret \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic voice-redis-ors-stream \
  --from-literal=voice_redis_ors_stream="{
      \"password\":\"${ges_redis_ors_password}\",
      \"port\":\"${REDIS_PORT}\",
      \"rejectUnauthorized\":\"true\",
      \"servername\":\"${ges_redis_ors_host}\"
}" \
  --dry-run=client -o yaml | kubectl apply -f -
###############################################################################

###############################################################################
# Creating GES DB if not exists
###############################################################################
create_pg_db $ges_db_name $ges_db_name $ges_db_name