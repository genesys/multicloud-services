###############################################################################
# Attention: gca should be deployed after tenant, gim, gsp because it relies on 
# deployment-secrets in corresponding namespace!
###############################################################################
function get_secret {
	# Using: get_secret secret_name [namespace secret-name]
  ds=${3:-deployment-secrets}
  ns=$NS
  [ "$2" ] && ns=$2
	echo $( kubectl -n $ns get secrets $ds -o custom-columns=:data.$1 \
			--no-headers | base64 -d )
}

function replace_overrides {
  # Using: replace_overrides old_value new_value
  ESCAPED_S=$(printf '%s' "$2" | sed -e 's/[\/&]/\\&/g')
  cat override_values.yaml | sed "s/$1/$ESCAPED_S/g" > override_values.tmp \
     && mv override_values.tmp override_values.yaml 
}

###############################################################################
#       Tenant id (UUID) and sid from GIM deployment secrets
###############################################################################
export tenant_sid=$( get_secret tenant_sid gim )
export tenant_id=$( get_secret tenant_id gim )
###############################################################################
#       GIM database parameters from GIM deployment secrets
###############################################################################
export POSTGRES_ADDR_GIM=$( get_secret gim_pgdb_server gim )
export gim_pgdb_etl_name=$( get_secret gim_pgdb_etl_name gim )
export gim_pgdb_etl_user=$( get_secret gim_pgdb_etl_user gim )
export gim_pgdb_etl_password=$( get_secret gim_pgdb_etl_password gim )
###############################################################################
#             Tenant DB information from tenant deployment secrets
###############################################################################
export POSTGRES_ADDR_TENANT=$( get_secret POSTGRES_ADDR voice )
export tenant_pg_db_name=$( get_secret tenant_t${tenant_sid}_pg_db_name voice )
export tenant_pg_db_user=$( get_secret tenant_t${tenant_sid}_pg_db_user voice )
export tenant_pg_db_password=$( get_secret tenant_t${tenant_sid}_pg_db_password voice )
###############################################################################
#          Object bucket credentials from GSP secrets (gim secrets)
###############################################################################
export s3_access_key=$( get_secret AWS_ACCESS_KEY_ID gsp gim )
export s3_secret_key=$( get_secret AWS_SECRET_ACCESS_KEY gsp gim )
###############################################################################
#          Object bucket name from gim config map in gsp namespace
###############################################################################
export bucket_name=$(kubectl -n gsp get cm gim -o jsonpath='{.data.BUCKET_NAME}')
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides {tenant_sid}          $tenant_sid
replace_overrides {tenant_id}           $tenant_id
replace_overrides POSTGRES_ADDR_GIM     $POSTGRES_ADDR_GIM
replace_overrides gim_pgdb_etl_name     $gim_pgdb_etl_name
replace_overrides gim_pgdb_etl_user     $gim_pgdb_etl_user
replace_overrides gim_pgdb_etl_password $gim_pgdb_etl_password
replace_overrides POSTGRES_ADDR_TENANT  $POSTGRES_ADDR_TENANT
replace_overrides tenant_pg_db_name     $tenant_pg_db_name
replace_overrides tenant_pg_db_user     $tenant_pg_db_user
replace_overrides tenant_pg_db_password $tenant_pg_db_password
replace_overrides s3_access_key         $s3_access_key
replace_overrides s3_secret_key         $s3_secret_key
replace_overrides bucket_name           $bucket_name