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
  if ! (kubectl get secret $1 > /dev/null); then
    echo "Creating $1 secret"
    kubectl create secret generic $1
  fi

  if ! (kubectl get secret $1 -o jsonpath="{.data.$2}" | base64 -d | grep $3 > /dev/null)
  then
    ESCAPED_3=$(printf '%s' "$3" | sed -e 's/[$\*=!]/\\&/g')
    echo "$2 secret does not exist or does not match. Creating it"
    kubectl get secret $1 -o json | \
      jq --arg key $2 --arg val "$(echo -n $ESCAPED_3 | base64 )" '.data[$key]=$val' | \
      kubectl apply -f -
  else
    echo "$1 secret already exist"
  fi
}


###############################################################################
#             MS SQL connection information and credentials
###############################################################################
export gvp_mssql_db_server=$( get_secret gvp_mssql_db_server )
export gvp_rs_mssql_db_name=$( get_secret gvp_rs_mssql_db_name )
export gvp_rs_mssql_db_password=$( get_secret gvp_rs_mssql_db_password )
export gvp_rs_mssql_db_user=$( get_secret gvp_rs_mssql_db_user )
export gvp_rs_mssql_admin_password=$( get_secret gvp_rs_mssql_admin_password )
export gvp_rs_mssql_reader_password=$( get_secret gvp_rs_mssql_reader_password )
###############################################################################

###############################################################################
#             Secrets for GVP Configuration Server
#
# https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#Secrets_creation_3
###############################################################################
create_secret rs-dbreader-password  db-hostname   $gvp_mssql_db_server
create_secret rs-dbreader-password  db-name       $gvp_rs_mssql_db_name
create_secret rs-dbreader-password  db-password   $gvp_rs_mssql_db_password
create_secret rs-dbreader-password  db-username   $gvp_rs_mssql_db_user
create_secret shared-gvp-rs-sqlserver-secret   db-admin-password    $gvp_rs_mssql_admin_password
create_secret shared-gvp-rs-sqlserver-secret   db-reader-password   $gvp_rs_mssql_reader_password
###############################################################################