#!/usr/bin/env bash

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
# 					Posgress address and database
###############################################################################
export POSTGRES_ADDR=$(find_in_overrides ".postgres.host" "host:" "postgres")
export DB_NAME=$(find_in_overrides ".postgres.db" "db:" "db:")
###############################################################################
# 					Posgress gauth credentials
######### gauth_pg_username/gauth_pg_password #################################
export gauth_pg_username=$( get_secret gauth_pg_username )
export gauth_pg_password=$( get_secret gauth_pg_password )
###############################################################################
# 			Posgress admin credentials (uses for creating gauth db)
######### POSTGRES_ADMIN_USER/POSTGRES_ADMIN_PASS #############################
export POSTGRES_ADMIN_USER=$( get_secret POSTGRES_ADMIN_USER )
export POSTGRES_ADMIN_PASS=$( get_secret POSTGRES_ADMIN_PASS )
###############################################################################
# 						Redis credentials
######### gauth_redis_password ################################################
export gauth_redis_password=$( get_secret gauth_redis_password )
###############################################################################
# 						Gauth credentials
######### gauth_admin_username/gauth_admin_password ###########################
export gauth_admin_username=$( get_secret gauth_admin_username )
export gauth_admin_password=$( get_secret gauth_admin_password )
###############################################################################
# GWS credentials
######### gauth_gws_client_id/gauth_gws_client_secret ###########################
export gauth_gws_client_id=$( get_secret gauth_gws_client_id )
export gauth_gws_client_secret=$( get_secret gauth_gws_client_secret )
###############################################################################
# Gauth jks credentials
######### gauth_jks_keyStorePassword ##########################################
export gauth_jks_keyPassword=$( get_secret gauth_jks_keyPassword )
export gauth_jks_keyStorePassword=$( get_secret gauth_jks_keyStorePassword )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides gauth_pg_username $gauth_pg_username
replace_overrides gauth_pg_password $gauth_pg_password
replace_overrides gauth_redis_password $gauth_redis_password
replace_overrides gauth_admin_username $gauth_admin_username
replace_overrides gauth_admin_password $gauth_admin_password
replace_overrides gauth_gws_client_id $gauth_gws_client_id
replace_overrides gauth_gws_client_secret $gauth_gws_client_secret
replace_overrides gauth_jks_keyPassword $gauth_jks_keyPassword
replace_overrides gauth_jks_keyStorePassword $gauth_jks_keyStorePassword

###############################################################################
# Creating gauth DB if not exist
###############################################################################
envsubst < create_gauth_db.sh > create_gauth_db.sh_
kubectl delete pods busybox || true
kubectl run busybox --image=alpine --restart=Never -- sh -c "$(<create_gauth_db.sh_)"
sleep 15
kubectl delete pods busybox || true
