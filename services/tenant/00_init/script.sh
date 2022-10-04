function create_secret {
  # Using: create_secret secret_name secret_key secret_value
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

######## Mandatory variables

[[ ! "$tenant_gws_client_id" ]]     && error_exit "provide tenant_gws_client_id via deployment secrets"
[[ ! "$tenant_gws_client_secret" ]] && error_exit "provide tenant_gws_client_secret via deployment secrets"

######## Optional variables with defaults

[[ "$POSTGRES_STD_ADDR" ]]    && export POSTGRES_ADDR="$POSTGRES_STD_ADDR"
[[ "$tenant_pg_db_server" ]]  && export POSTGRES_ADDR="$tenant_pg_db_server"
[[ "$tenant_pg_admin" ]]      && export POSTGRES_USER="$tenant_pg_admin"
[[ "$tenant_pg_admin_pass" ]] && export POSTGRES_PASSWORD="$tenant_pg_admin_pass"

tdbname="tenant_t${TENANT_SID}_pg_db_name"
tdbuser="tenant_t${TENANT_SID}_pg_db_user"
tdbpass="tenant_t${TENANT_SID}_pg_db_pass"
[[ "${!tdbname}" ]] && export tenant_db_name=${!tdbname} || export tenant_db_name="t${TENANT_SID}"
[[ "${!tdbuser}" ]] && export tenant_db_user=${!tdbuser} || export tenant_db_user="t${TENANT_SID}"
[[ "${!tdbpass}" ]] && export tenant_db_pass=${!tdbpass} || export tenant_db_pass="t${TENANT_SID}"


######## Creating secrets

create_secret dbserver                    dbserver      $POSTGRES_ADDR
create_secret dbname-t${TENANT_SID}       dbname        $tenant_db_name
create_secret dbuser-t${TENANT_SID}       dbuser        $tenant_db_user
create_secret dbpassword-t${TENANT_SID}   dbpassword    $tenant_db_pass
create_secret gauthclientid               clientid      $tenant_gws_client_id
create_secret gauthclientsecret           clientsecret  $tenant_gws_client_secret


######### Creating tenant DB and user

create_pg_db $tenant_db_name $tenant_db_user $tenant_db_pass