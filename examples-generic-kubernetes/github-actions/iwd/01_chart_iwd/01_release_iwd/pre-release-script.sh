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
# 			Nexus postgres credentials
###############################################################################
export iwd_db_user=$( get_secret iwd_db_user )
export iwd_db_password=$( get_secret iwd_db_password )
###############################################################################
# 			Redis password
###############################################################################
export iwd_redis_password=$( get_secret iwd_redis_password )
###############################################################################
# 			Auth credentials
###############################################################################
export iwd_gws_client_id=$( get_secret iwd_gws_client_id )
export iwd_gws_client_secret=$( get_secret iwd_gws_client_secret )
###############################################################################
# 			Tenant id (UUID), sid and locations
###############################################################################
export tenant_sid=$( get_secret tenant_sid )
export tenant_id=$( get_secret tenant_id )
###############################################################################
# 			Nexus API keys
# in nexus db: SELECT id,name FROM nex_apikeys
###############################################################################
export iwd_gws_api_key=$( get_secret iwd_gws_api_key )
export iwd_nexus_api_key=$( get_secret iwd_nexus_api_key )
export iwd_tenant_api_key=$( get_secret iwd_tenant_api_key )
###############################################################################
# 			Generated new apikeys for tenant and iwddm:
#
# echo  "$(uuidgen)" | tr '[:upper:]' '[:lower:]')
###############################################################################
export iwd_tenant_api_key_iwddm=$( get_secret iwd_tenant_api_key_iwddm )
export iwd_tenant_api_key_tenant=$( get_secret iwd_tenant_api_key_tenant )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides POSTGRES_ADDR 				$POSTGRES_ADDR
replace_overrides iwd_gws_client_id 		$iwd_gws_client_id
replace_overrides iwd_gws_client_secret $iwd_gws_client_secret
replace_overrides iwd_redis_password 		$iwd_redis_password
replace_overrides iwd_gws_api_key 			$iwd_gws_api_key
replace_overrides iwd_nexus_api_key 		$iwd_nexus_api_key
replace_overrides iwd_tenant_api_key 		$iwd_tenant_api_key

##############################################################################
# Creating IWD DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"