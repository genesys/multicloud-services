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
# 					Postgres address
###############################################################################
export POSTGRES_ADDR=$( get_secret POSTGRES_ADDR )
###############################################################################
# 			Posgress admin credentials (uses for creating iwd db)
###############################################################################
export POSTGRES_USER=$( get_secret POSTGRES_USER )
export POSTGRES_PASSWORD=$( get_secret POSTGRES_PASSWORD )
###############################################################################
# 					IXN DB names - reading from overrides
###############################################################################
export IXN_DB=$( get_secret IXN_DB )
export IXN_NODE_DB=$( get_secret IXN_NODE_DB )
###############################################################################
# 			IXN postgres credentials
###############################################################################
export ixn_db_user=$( get_secret ixn_db_user )
export ixn_db_password=$( get_secret ixn_db_password )
###############################################################################
# 			Redis password
###############################################################################
export redis_password=$( get_secret redis_password )
###############################################################################
# 			Tenant id (UUID), sid and locations
###############################################################################
export tenant_sid=$( get_secret tenant_sid )
export tenant_id=$( get_secret tenant_id )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides POSTGRES_ADDR 	$POSTGRES_ADDR
replace_overrides IXN_DB 					$IXN_DB
replace_overrides IXN_NODE_DB 		$IXN_NODE_DB
replace_overrides tenant_id 			$tenant_id
replace_overrides tenant_sid 			$tenant_sid

###############################################################################
# 					Redis and Kafka addresses - reading from overrides
###############################################################################
export REDIS_ADDR=$(find_in_overrides ".ixnService.ixnNode.redis[0].host" "host:" "redis")
export REDIS_PORT=$(find_in_overrides ".ixnService.ixnNode.redis[0].port" "port:" "6379")
export KAFKA_ADDR=$(find_in_overrides ".kafkaAddress" "kafkaAddress:" "kafka")
###############################################################################


###############################################################################
# 					Creating redis and kafka secrets
#
# https://all.docs.genesys.com/IXN/Current/IXNPEGuide/Deploy#Create_secrets
###############################################################################
cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: redis-ors-secret
  namespace: ${NS}
type: Opaque
stringData:
  voice-redis-ors-stream: "{\"password\":\"${redis_password}\",\"port\":${REDIS_PORT},\"rejectUnauthorized\":false,\"servername\":\"${REDIS_ADDR}\"}"
EOF

cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: kafka-shared-secret
  namespace: ${NS}
type: Opaque
stringData:
  kafka-secrets: "{\"bootstrap\": \"${KAFKA_ADDR}:9092\"}"
EOF
##############################################################################


##############################################################################
# Creating IWD DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl delete pods busybox || true
kubectl run busybox --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"
sleep 15
kubectl delete pods busybox || true