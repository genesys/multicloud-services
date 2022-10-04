###############################################################################
#	Interaction Server (IXN) is deployed per-tenant
#	https://all.docs.genesys.com/IXN/Current/IXNPEGuide/ArchitectureIXN
###############################################################################

# TENANT_SID and TENANT_UUID (as well as other Postgre and Redis-related variables) 
# are supposed to be already defined via Deployment Secrets (DS)

# IXN requires two databases - IXN and IXN-node
# These is default db naming, but you can redefine via DS:
[[ ! "$ixn_db_name" ]] && export ixn_db_name=ixn-$TENANT_SID
[[ ! "$ixn_node_db_name" ]] && export ixn_node_db_name=ixn-node-$TENANT_SID

[[ ! "$ixn_db_user" ]] && export ixn_db_user="ixn"
[[ ! "$ixn_db_password" ]] && export ixn_db_password="ixn"

# We will be using Postgre instance $POSTGRES_DGT_ADDR (defined via DS)
[[ "$POSTGRES_DGT_ADDR" ]] && export POSTGRES_ADDR=$POSTGRES_DGT_ADDR


###############################################################################
# 	Creating redis and kafka secrets
# 	https://all.docs.genesys.com/IXN/Current/IXNPEGuide/Deploy#Create_secrets
###############################################################################
cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: redis-ors-secret
  namespace: ${NS}
type: Opaque
stringData:
  voice-redis-ors-stream: "{\"password\":\"${REDIS_PASSWORD}\",\"port\":${REDIS_PORT},\"rejectUnauthorized\":false,\"servername\":\"${REDIS_ADDR}\"}"
EOF

cat <<EOF | kubectl apply -f -
kind: Secret
apiVersion: v1
metadata:
  name: kafka-shared-secret
  namespace: ${NS}
type: Opaque
stringData:
  kafka-secrets: "{\"bootstrap\": \"${KAFKA_ADDR}:9092\"}"
EOF
##############################################################################


##############################################################################
# Creating IXN DBs if not exist
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl delete pods busybox || true
kubectl run busybox --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"