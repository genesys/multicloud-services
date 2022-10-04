###############################################################################
# Creating secrets: gcxi-secret-gauth and gcxi-secret-pg
###############################################################################
cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: gcxi-secret-gauth
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
type: Opaque
stringData:
  META_DB_ADMIN: ${POSTGRES_USER}
  META_DB_ADMINPWD: '${POSTGRES_PASSWORD}'
EOF

###############################################################################
# Creating config-map: gcxi-secret-gauth and gcxi-secret-pg
###############################################################################
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: gcxi-config-pg
data:
  META_DB_HOST: "${gcxi_db_host}"
  META_DB_PORT: "5432"
  META_DB_ADMINDB: "postgres"
EOF