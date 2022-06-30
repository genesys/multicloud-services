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

###############################################################################
#           Postgres address
###############################################################################
export POSTGRES_ADDR=$( get_secret gim_pgdb_server )
###############################################################################
#       Posgres admin credentials (uses for creating GIM db)
###############################################################################
export POSTGRES_USER=$( get_secret POSTGRES_USER )
export POSTGRES_PASSWORD=$( get_secret POSTGRES_PASSWORD )
###############################################################################
#       GIM DB credentials 
###############################################################################
export gim_pgdb_etl_name=$( get_secret gim_pgdb_etl_name )
export gim_pgdb_etl_user=$( get_secret gim_pgdb_etl_user )
export gim_pgdb_etl_password=$( get_secret gim_pgdb_etl_password )
###############################################################################
#       Tenant id (UUID), sid and locations
###############################################################################
export tenant_sid=$( get_secret tenant_sid )
export tenant_id=$( get_secret tenant_id )
###############################################################################
#       kafka
###############################################################################
export KAFKA_ADDR=$( get_secret KAFKA_ADDR )

###############################################################################
# Creating GIM DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"