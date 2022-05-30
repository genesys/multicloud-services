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
# 			Posgress admin credentials (uses for creating nexus db)
###############################################################################
export POSTGRES_USER=$( get_secret POSTGRES_USER )
export POSTGRES_PASSWORD=$( get_secret POSTGRES_PASSWORD )
###############################################################################
# 			iwddm, gcxi and gim postgres credentials
###############################################################################
export iwddm_db_user=$( get_secret iwddm_db_user )
export iwddm_db_password=$( get_secret iwddm_db_password )
export gcxi_db_user=$( get_secret gcxi_db_user )
export gcxi_db_password=$( get_secret gcxi_db_password )
export gim_db_user=$( get_secret gim_db_user )
export gim_db_password=$( get_secret gim_db_password )
###############################################################################
# 			Tenant id (UUID), sid and locations
###############################################################################
export tenant_sid=$( get_secret tenant_sid )
###############################################################################
# 			Nexus API keys
# in nexus db: SELECT id,name FROM nex_apikeys
###############################################################################
export iwddm_nexus_api_key=$( get_secret iwddm_nexus_api_key )
###############################################################################


# For validation process need to evaluate release override values here
replace_overrides POSTGRES_ADDR 		$POSTGRES_ADDR
replace_overrides iwddm_db_user 		$iwddm_db_user
replace_overrides iwddm_db_password $iwddm_db_password

###############################################################################
# 			Provisioning secrets: 
#
# https://all.docs.genesys.com/PEC-IWD/Current/IWDDMPEGuide/Configure#Secrets
###############################################################################
kubectl create secret generic iwd-secrets-${tenant_sid} --dry-run=client -o yaml \
		--from-literal="IWDDM_API_KEY=${iwddm_nexus_api_key}" | kubectl apply -f -
cat <<EOF > gim-secret.txt
IWDDM_GIM_DBUSER=$gim_db_user
IWDDM_GIM_PASSWORD=$gim_db_password
IWDDM_GIM_URL=jdbc:postgresql://${POSTGRES_ADDR}:5432/etl-aro
EOF
kubectl create secret generic gim-secrets-${tenant_sid} \
		--from-file=gim-secret.txt --dry-run=client -o yaml | kubectl apply -f -
###############################################################################



##############################################################################
# Creating Nexus DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"