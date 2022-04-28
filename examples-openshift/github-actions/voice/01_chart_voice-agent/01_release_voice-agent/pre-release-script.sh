
###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
#                 Using it! 
# We extract secrets to environment variables. It will evaluate variables in
# override values by workflow.
###############################################################################
function get_secret {
  # Using: get_secret secret_name
  echo $( kubectl get secrets deployment-secrets -o custom-columns=:data.$1 \
      --no-headers | base64 -d )
}

function create_secret {
  # Using: create_secret secret_name secrete_value_name secret_value
  if ! (kubectl get secret $1 -o jsonpath="{.data.$2}" | base64 -d | grep $3)
  then
    ESCAPED_3=$(printf '%s' "$3" | sed -e 's/[$\*=!]/\\&/g')
    echo "$2 secret does not exist or does not match. Creating it"
    kubectl delete secret $1  -n $NS || true
    kubectl create secret generic $1 -n $NS --from-literal=$2=$ESCAPED_3
  else
    echo "$1 secret already exist"
  fi
}

function create_endpoint {
  # Using: create_endpont redis_service_name
  if ! (kubectl get endpoints $1 -n $NS | grep  $REDIS_IP:$REDIS_PORT)  ; then
    echo "Endpoint $1 do not exist. Creating them"
    export REDIS_SERVICE_NAME=$1
    envsubst < redis-services.yaml | kubectl apply -n $NS -f -
  else
    echo "Endpoint $1 already exist"
  fi
}


###############################################################################
#             REDIS connection address and credentials
###############################################################################
export REDIS_PASSWORD=$( get_secret REDIS_PASSWORD )
export REDIS_IP=$( get_secret REDIS_IP )
export REDIS_PORT=$( get_secret REDIS_PORT )
###############################################################################
#             CONSUL credentials
###############################################################################
export CONSUL_VOICE_TOKEN=$( get_secret CONSUL_VOICE_TOKEN )
###############################################################################
#             KAFKA connection address
###############################################################################
export KAFKA_ADDRESS=$( get_secret KAFKA_ADDRESS )
###############################################################################


###############################################################################
#             Secrets for voice microservices
#
# https://all.docs.genesys.com/VM/Current/VMPEGuide/Configure#Secrets_for_Voice_Services
###############################################################################
create_secret consul-voice-token      consul-consul-voice-token $CONSUL_VOICE_TOKEN
create_secret kafka-secrets-token     kafka-secrets           {\"bootstrap\":\"$KAFKA_ADDRESS\"}
create_secret redis-agent-token       redis-agent-state       {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-callthread-token  redis-call-state        {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-config-token      redis-config-state      {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-ors-token         redis-ors-state         {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-ors-stream-token  redis-ors-stream        {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-registrar-token   redis-registrar-state   {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-rq-token          redis-rq-state          {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-sip-token         redis-sip-state         {\"password\":\"$REDIS_PASSWORD\"}
create_secret redis-tenant-token      redis-tenant-stream     {\"password\":\"$REDIS_PASSWORD\"}
###############################################################################


###############################################################################
#             Services and edpoints creation
#
# https://all.docs.genesys.com/VM/Current/VMPEGuide/Deploy#Deploy_Voice_Services
###############################################################################
create_endpoint redis-agent-state 
create_endpoint redis-call-state 
create_endpoint redis-config-state 
create_endpoint redis-ors-state 
create_endpoint redis-ors-stream 
create_endpoint redis-registrar-state 
create_endpoint redis-rq-state 
create_endpoint redis-sip-state 
create_endpoint redis-tenant-stream


