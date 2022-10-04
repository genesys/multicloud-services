##############################################################################
# Default deployment parameters
###############################################################################

# Use $voice_consul_token if defined, otherwise use global $CONSUL_BOOT_TOKEN
[[ ! "$CONSUL_VOICE_TOKEN" ]] && export CONSUL_VOICE_TOKEN="$CONSUL_BOOT_TOKEN"
[[ "$voice_consul_token" ]]   && export CONSUL_VOICE_TOKEN="$voice_consul_token"

# Redis info from your depl secrets, or use globally defined Redis
[[ ! "$voice_redis_port" ]]     && export voice_redis_port=$REDIS_PORT
[[ ! "$voice_redis_password" ]] && export voice_redis_password=$REDIS_PASSWORD
if [ ! "$voice_redis_ip" ]; then
    # Using $REDIS_ADDR from globals. We need IP address of redis service.
    
    # if it is IP address
    if [[ $REDIS_ADDR =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        export voice_redis_ip=$REDIS_ADDR
    # otherwise it is supposed to be domain name of redis service
    else
        export voice_redis_ip=$(kubectl get service $(echo $REDIS_ADDR| cut -d'.' -f1) \
          -n $(echo $REDIS_ADDR| cut -d'.' -f2) --no-headers| grep ClusterIP| awk '{print $3}')
    fi

    [[ ! $voice_redis_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && error_exit "failed to obtain Redis address"
fi

# Take voice_dns_ip value (IP address) from depl secrets, 
# or from DNS operator (Openshift), or kube-dns
if [ ! "$voice_dns_ip" ]; then
    if [ "$CLUSTER_TYPE" == "openshift" ]; then
        export voice_dns_ip=$(kubectl get dns.operator/default -o jsonpath={.status.clusterIP})
    else
        export voice_dns_ip=$(kubectl get svc kube-dns -n kube-system -o jsonpath={.spec.clusterIP})
    fi
fi


###############################################################################
# Helper functions for voice microservices
###############################################################################

function create_secret {
    ##########################################################
    # Using: create_secret secret_name secret_key secret_value
    ##########################################################
    if ! (kubectl get secret $1 -o jsonpath="{.data.$2}" | base64 -d | grep $3)
    then
        ESCAPED_3=$(printf '%s' "$3" | sed -e 's/[$\*=!]/\\&/g')
        echo "Secret $1 (key $2) does not exist or does not match. Creating it"
        kubectl create secret generic $1 --from-literal=$2=$ESCAPED_3 \
          --dry-run -o yaml | kubectl apply -f -
    else
        echo "Secret $1 (key $2) already exists"
    fi
}

function create_endpoint {
    ##########################################
    # Using: create_endpont redis_service_name
    ##########################################
    if ! (kubectl get endpoints $1 | grep  $voice_redis_ip:$voice_redis_port)  ; then
        echo "Endpoint $1 does not exist. Creating it with IP $voice_redis_ip"
        export REDIS_SERVICE_NAME=$1
        envsubst < redis-services.yaml | kubectl apply -f -
    else
        echo "Endpoint $1 already exists"
    fi
}


###############################################################################
# Secrets for voice microservices
# https://all.docs.genesys.com/VM/Current/VMPEGuide/Configure#Secrets_for_Voice_Services
###############################################################################
create_secret consul-voice-token      consul-consul-voice-token $CONSUL_VOICE_TOKEN
create_secret kafka-secrets-token     kafka-secrets           {\"bootstrap\":\"$KAFKA_ADDR:$KAFKA_PORT\"}
create_secret redis-agent-token       redis-agent-state       {\"password\":\"$voice_redis_password\"}
create_secret redis-callthread-token  redis-call-state        {\"password\":\"$voice_redis_password\"}
create_secret redis-config-token      redis-config-state      {\"password\":\"$voice_redis_password\"}
create_secret redis-ors-token         redis-ors-state         {\"password\":\"$voice_redis_password\"}
create_secret redis-ors-stream-token  redis-ors-stream        {\"password\":\"$voice_redis_password\"}
create_secret redis-registrar-token   redis-registrar-state   {\"password\":\"$voice_redis_password\"}
create_secret redis-rq-token          redis-rq-state          {\"password\":\"$voice_redis_password\"}
create_secret redis-sip-token         redis-sip-state         {\"password\":\"$voice_redis_password\"}
create_secret redis-tenant-token      redis-tenant-stream     {\"password\":\"$voice_redis_password\"}
###############################################################################


###############################################################################
# Services and edpoints creation
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

# Allow connectivity via Consul service mesh
create_consul_intention

return 0