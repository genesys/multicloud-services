
###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
#                 Using it! 
# We extract secrets to environment variables. It will evaluate variables in
# override values by workflow.
###############################################################################
function get_secret {
  # Using: get_secret secret_name
  echo $( kubectl get secrets deployment-secrets -o custom-columns=:data.$1 \
      --no-headers | base64 -d )
}

function create_secret {
  # Using: create_secret secret_name secrete_value_name secret_value
  if ! (kubectl get secret $1 -o jsonpath="{.data.$2}" | base64 -d | grep $3)
  then
    ESCAPED_3=$(printf '%s' "$3" | sed -e 's/[$\*=!]/\\&/g')
    echo "$2 secret does not exist or does not match. Creating it"
    kubectl delete secret $1  -n $NS || true
    kubectl create secret generic $1 -n $NS --from-literal=$2=$ESCAPED_3
  else
    echo "$1 secret already exist"
  fi
}

###############################################################################
#             POSTGRES connection information and credentials
###############################################################################
export POSTGRES_ADDR=$( get_secret POSTGRES_ADDR )
export tenant_t100_pg_db_name=$( get_secret tenant_t100_pg_db_name )
export tenant_t100_pg_db_user=$( get_secret tenant_t100_pg_db_user )
export tenant_t100_pg_db_password=$( get_secret tenant_t100_pg_db_password )
###############################################################################
#             GAUTH credentials
###############################################################################
export tenant_gauth_client_id=$( get_secret tenant_gauth_client_id )
export tenant_gauth_client_secret=$( get_secret tenant_gauth_client_secret )
###############################################################################
#       Postgres admin credentials (uses for creating tenant db)
###############################################################################
export POSTGRES_USER=$( get_secret POSTGRES_USER )
export POSTGRES_PASSWORD=$( get_secret POSTGRES_PASSWORD )
###############################################################################


###############################################################################
#             Secrets for voice microservices
#
# https://all.docs.genesys.com/PrivateEdition/Current/TenantPEGuide/Configure#Service-specific_secrets
###############################################################################
create_secret dbserver          dbserver      $POSTGRES_ADDR
create_secret dbname            dbname        $tenant_t100_pg_db_name
create_secret dbuser            dbuser        $tenant_t100_pg_db_user
create_secret dbpassword        dbpassword    $tenant_t100_pg_db_password
create_secret gauthclientid     clientid      $tenant_gauth_client_id
create_secret gauthclientsecret clientsecret  $tenant_gauth_client_secret
###############################################################################

###############################################################################
# Creating tenant DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i -rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"
###############################################################################

###############################################################################
#               Creating PVC for log
###############################################################################
cat << EOF | kubectl apply -n $NS -f - 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: log-pvc
  labels:
    service: tenant
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: microk8s-hostpath
EOF
###############################################################################

