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
# 					Postgres address and database
###############################################################################
export POSTGRES_ADDR=$(find_in_overrides ".db.host" "host:" "postgres")
export DB_NAME_UCSX=$(find_in_overrides ".db.name" "ucsx_tenant" "db_name")
###############################################################################
# 			Postgres admin credentials (uses for creating ucsx db)
export ucsx_master_db_user=$( get_secret ucsx_master_db_user )
export ucsx_master_db_password=$( get_secret ucsx_master_db_password )
###############################################################################
# 			Postgres admin credentials (uses for creating ucsx-tenant db)
###############################################################################
export ucsx_tenant_db_user=$(find_in_overrides ".db.user" "ucsx_tenant:" "db_user")
export ucsx_tenant_db_password=$(find_in_overrides ".db.password" "ucsx_tenant:" "db_password")
###############################################################################
# 					Gauth ucsx credentials 
###############################################################################
export ucsx_gauth_client_id=$( get_secret ucsx_gauth_client_id )
export ucsx_gauth_client_secret=$( get_secret ucsx_gauth_client_secret )
###############################################################################
# Tenant details
###############################################################################
export ucsx_sid=$( get_secret ucsx_sid)
export ucsx_tenant_id=$( get_secret ucsx_tenant_id)
export ucsx_registry=$( get_secret ucsx_registry)

# For validation process need to evaluate release override values here
replace_overrides ucsx_gauth_client_id 			$ucsx_gauth_client_id
replace_overrides ucsx_gauth_client_secret 		$ucsx_gauth_client_secret
replace_overrides ucsx_sid						$ucsx_sid
replace_overrides ucsx_tenant_id				$ucsx_tenant_id
replace_overrides ucsx_registry					$ucsx_registry

###############################################################################
# Creating UCSX DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl delete pods busybox || true
kubectl run busybox --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"
sleep 15
kubectl delete pods busybox || true
