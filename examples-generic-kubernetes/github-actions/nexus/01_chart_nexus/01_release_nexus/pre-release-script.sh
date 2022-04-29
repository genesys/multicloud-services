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
# 					Postgres address
###############################################################################
export POSTGRES_ADDR=$(find_in_overrides ".nexus.db.host" "host:" "postgres")
###############################################################################
# 			Posgress admin credentials (uses for creating nexus db)
###############################################################################
export pg_admin_user=$( get_secret pg_admin_user )
export pg_admin_pass=$( get_secret pg_admin_pass )
###############################################################################
# 			Nexus postgres credentials
###############################################################################
export nexus_db_user=$( get_secret nexus_db_user )
export nexus_db_password=$( get_secret nexus_db_password )
###############################################################################
# 			Redis password
###############################################################################
export nexus_redis_password=$( get_secret nexus_redis_password )
###############################################################################
# 			Auth credentials
###############################################################################
export nexus_gws_client_id=$( get_secret nexus_gws_client_id )
export nexus_gws_client_secret=$( get_secret nexus_gws_client_secret )
###############################################################################
# 			Tenant id (UUID), sid and locations
###############################################################################
export tenant_sid=$( get_secret tenant_sid )
export tenant_id=$( get_secret tenant_id )
export tenant_primary_location=$( get_secret tenant_primary_location )
export tenant_locations=$( get_secret tenant_locations )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides nexus_redis_password 		$nexus_redis_password
replace_overrides nexus_db_user 			$nexus_db_user
replace_overrides nexus_db_password 		$nexus_db_password

##############################################################################
# Creating Nexus DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl delete pods busybox || true
kubectl run busybox --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"
sleep 15
kubectl delete pods busybox || true