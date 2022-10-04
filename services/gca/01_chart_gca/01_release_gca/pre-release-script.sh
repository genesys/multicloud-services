###############################################################################
# ❗ Attention: gca should be deployed after tenant, gim, gsp 
#    because it relies on specific secrets in corresponding namespaces
###############################################################################

###############################################################################
#   GIM database parameters from GIM "gim-secrets", if not defined in DS
###############################################################################
[[ "$POSTGRES_RPTHIST_ADDR" ]] && export POSTGRES_ADDR_GIM=$POSTGRES_RPTHIST_ADDR
[[ ! "$POSTGRES_ADDR_GIM" ]]   && export POSTGRES_ADDR_GIM=$( kubectl get secret gim-gim-secrets -n gim -o json | jq -r --arg tid "gim-t100" '.data[$tid]'| base64 -d | jq -r .db_hostname )
[[ ! "$gim_pgdb_etl_name" ]]   && export gim_pgdb_etl_name=$( kubectl get secret gim-gim-secrets -n gim -o json | jq -r --arg tid "gim-t100" '.data[$tid]'| base64 -d | jq -r .db_name )
[[ ! "$gim_pgdb_etl_user" ]]   && export gim_pgdb_etl_user=$( kubectl get secret gim-gim-secrets -n gim -o json | jq -r --arg tid "gim-t100" '.data[$tid]'| base64 -d | jq -r .db_username )
[[ ! "$gim_pgdb_etl_pass" ]]   && export gim_pgdb_etl_pass=$( kubectl get secret gim-gim-secrets -n gim -o json | jq -r --arg tid "gim-t100" '.data[$tid]'| base64 -d | jq -r .db_password )

###############################################################################
#   Tenant DB information from tenant's secrets, if not defined in DS
###############################################################################
[[ "$POSTGRES_STD_ADDR" ]] && export POSTGRES_ADDR_TENANT=$POSTGRES_STD_ADDR
[[ ! "$POSTGRES_ADDR_TENANT" ]] && export POSTGRES_ADDR_TENANT=$( kubectl get secret dbserver -n voice -o json | jq -r '.data.dbserver' | base64 -d )
[[ ! "$tenant_pg_db_name" ]]    && export tenant_pg_db_name=$( kubectl get secret dbname -n voice -o json | jq -r '.data.dbname' | base64 -d )
[[ ! "$tenant_pg_db_user" ]]    && export tenant_pg_db_user=$( kubectl get secret dbuser -n voice -o json | jq -r '.data.dbuser' | base64 -d )
[[ ! "$tenant_pg_db_pass" ]]    && export tenant_pg_db_pass=$( kubectl get secret dbpassword -n voice -o json | jq -r '.data.dbpassword' | base64 -d )

###############################################################################
#   Object bucket credentials from GSP secrets (gim secrets)
###############################################################################
export s3_access_key=$( kubectl get secret gim -n gsp -o jsonpath={.data} | jq -r .AWS_ACCESS_KEY_ID | base64 -d )
export s3_secret_key=$( kubectl get secret gim -n gsp -o jsonpath={.data} | jq -r .AWS_SECRET_ACCESS_KEY | base64 -d )
export BUCKET_NAME=$( kubectl get cm gim -n gsp -o jsonpath={.data} | jq -r .BUCKET_NAME )
export BUCKET_HOST=$( kubectl get cm gim -n gsp -o jsonpath={.data} | jq -r .BUCKET_HOST )
export BUCKET_PORT=$( kubectl get cm gim -n gsp -o jsonpath={.data} | jq -r .BUCKET_PORT )
