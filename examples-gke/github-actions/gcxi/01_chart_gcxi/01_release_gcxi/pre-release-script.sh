###############################################################################
# Attention: GSXI should be deployed after GIM and IWD because it relies on 
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

###############################################################################
#       Tenant id (UUID) and sid from GIM deployment secrets
###############################################################################
export tenant_sid=$( get_secret tenant_sid gim )
export tenant_id=$( get_secret tenant_id gim )
###############################################################################
#       GIM database parameters from GIM deployment secrets
###############################################################################
export gim_db_name=$( get_secret gim_pgdb_etl_name gim )
export gim_db_user=$( get_secret gim_pgdb_etl_user gim )
export gim_db_pass=$( get_secret gim_pgdb_etl_password gim )
###############################################################################
#       IWD database parameters from GIM deployment secrets
###############################################################################
export iwd_db_name=iwd-$tenant_sid
export iwd_db_user=$( get_secret iwd_db_user iwd )
export iwd_db_pass=$( get_secret iwd_db_password iwd )
###############################################################################
#           Postgres address and admin_db
###############################################################################
export POSTGRES_ADDR=$( get_secret gcxi_db_host )
export META_DB_ADMINDB=$( get_secret gcxi_db_name )
###############################################################################
#       Posgress admin credentials
###############################################################################
export pg_admin_user=$( get_secret pg_admin_user )
export pg_admin_pass=$( get_secret pg_admin_pass )
###############################################################################
#       gcxi gauth credentials
###############################################################################
export GAUTH_CLIENT=$( get_secret GAUTH_CLIENT )
export GAUTH_KEY=$( get_secret GAUTH_KEY )
###############################################################################


###############################################################################
# Creating secrets: gcxi-secret-gauth and gcxi-secret-pg
###############################################################################
cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: gcxi-secret-gauth
  namespace: ${NS}
type: Opaque
stringData:
  GAUTH_CLIENT: ${GAUTH_CLIENT}
  GAUTH_KEY: ${GAUTH_KEY}
EOF

cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: gcxi-secret-pg
  namespace: ${NS}
type: Opaque
stringData:
  META_DB_ADMIN: ${pg_admin_user}
  META_DB_ADMINPWD: '${pg_admin_pass}'
EOF

###############################################################################
# Creating config-map: gcxi-secret-gauth and gcxi-secret-pg
###############################################################################
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: gcxi-config-pg
  namespace: ${NS}
data:
  META_DB_HOST: "${POSTGRES_ADDR}"
  META_DB_PORT: "5432"
  META_DB_ADMINDB: "${META_DB_ADMINDB}"
EOF