###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
# 								Using it! 
# We extract secrets to environment variables. It will evaluate variables in
# override values by workflow.
###############################################################################
function get_secret {
	# Using: get_secret secret_name
	echo $( kubectl get secrets deployment-secrets -o custom-columns=:data.$1 \
			--no-headers | base64 -d )
}

function replace_overrides {
  # Using: replace_overrides old_value new_value
  ESCAPED_S=$(printf '%s' "$2" | sed -e 's/[\/&]/\\&/g')
  cat override_values.yaml | sed "s/$1/$ESCAPED_S/g" > override_values.tmp \
     && mv override_values.tmp override_values.yaml 
}

function find_in_overrides {
  # Using: find_in_overrides yaml_path [lookup_arg1, lookup_arg2]
  #
  # try to parse by yq (if installed) then by awk (if false set to default)
  
  res=$(cat override_values.yaml | yq eval $1 - 2>/dev/null)
  if [[ ! "$res" ]] && [[ $2 ]] && [[ $3 ]]; then
    res=$(cat override_values.yaml | grep "$2" | grep "$3" \
        | awk '{print $2}')
  fi
  [[ ! "$res" ]] && res="not found"
  echo $res
}

###############################################################################
#           Postgres address
###############################################################################
export POSTGRES_ADDR=$( get_secret POSTGRES_ADDR )
###############################################################################
#       Posgress admin credentials (uses for creating GES db)
###############################################################################
export POSTGRES_USER=$( get_secret POSTGRES_USER )
export POSTGRES_PASSWORD=$( get_secret POSTGRES_PASSWORD )
###############################################################################
#       GES DB credentials 
###############################################################################
export DB_NAME=$( get_secret DB_NAME )
export DB_USER=$( get_secret DB_USER )
export DB_PASSWORD=$( get_secret DB_PASSWORD )
###############################################################################
#       GES credentials 
###############################################################################
export DEVOPS_USERNAME=$( get_secret DEVOPS_USERNAME )
export DEVOPS_PASSWORD=$( get_secret DEVOPS_PASSWORD )
###############################################################################
#      GES Redis and ORS Redis
###############################################################################
export REDIS_PASSWORD=$( get_secret REDIS_PASSWORD )
export REDIS_ORS_PASSWORD=$( get_secret REDIS_ORS_PASSWORD )
###############################################################################
#      GWS credentials
###############################################################################
export AUTHENTICATION_CLIENT_ID=$( get_secret AUTHENTICATION_CLIENT_ID )
export AUTHENTICATION_CLIENT_SECRET=$( get_secret AUTHENTICATION_CLIENT_SECRET )
###############################################################################
#      Voice ORS connection parameters (read from override-values)
###############################################################################
export VMCS_REDIS_HOST=$(find_in_overrides ".ges.configMap.integrations.vmcs.redis_host" "redis_host:" "redis_host")
export REDIS_PORT=$(find_in_overrides ".ges.configMap.integrations.vmcs.redis_port" "redis_port:" "redis_port")
###############################################################################


###############################################################################
# Creating secrets
###############################################################################
kubectl create secret generic ges-secrets-infra \
  --from-literal=DB-USER=$DB_USER \
  --from-literal=DB-PASSWORD=$DB_PASSWORD \
  --from-literal=REDIS_CACHEKEY=$REDIS_PASSWORD \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic gws-client-credentials \
  --from-literal=AUTHENTICATION-CLIENT-ID=$AUTHENTICATION_CLIENT_ID \
  --from-literal=AUTHENTICATION-CLIENT-SECRET=$AUTHENTICATION_CLIENT_SECRET \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic voice-redis-ors-stream \
  --from-literal=voice_redis_ors_stream="{
      \"password\":\"${REDIS_ORS_PASSWORD}\",
      \"port\":\"${REDIS_PORT}\",
      \"rejectUnauthorized\":\"true\",
      \"servername\":\"${VMCS_REDIS_HOST}\"
}" \
  --dry-run=client -o yaml | kubectl apply -f -
###############################################################################

###############################################################################
# Creating GES DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"