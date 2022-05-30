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
# 					Postgres address and database
###############################################################################
export POSTGRES_ADDR=$( get_secret POSTGRES_ADDR )
export DB_NAME_UCSX=$( get_secret DB_NAME_UCSX )
###############################################################################
# 			Postgres admin credentials (uses for creating gauth db)
export POSTGRES_USER=$( get_secret POSTGRES_USER )
export POSTGRES_PASSWORD=$( get_secret POSTGRES_PASSWORD )
###############################################################################
# 					Gauth ucsx credentials 
###############################################################################
export ucsx_gauth_client_id=$( get_secret ucsx_gauth_client_id )
export ucsx_gauth_client_secret=$( get_secret ucsx_gauth_client_secret )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides POSTGRES_ADDR 				$POSTGRES_ADDR
replace_overrides DB_NAME_UCSX 					$DB_NAME_UCSX
replace_overrides ucsx_gauth_client_id 			$ucsx_gauth_client_id
replace_overrides ucsx_gauth_client_secret 		$ucsx_gauth_client_secret
replace_overrides POSTGRES_USER 			$POSTGRES_USER
replace_overrides POSTGRES_PASSWORD 		$POSTGRES_PASSWORD

###############################################################################
# Creating UCSX DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"