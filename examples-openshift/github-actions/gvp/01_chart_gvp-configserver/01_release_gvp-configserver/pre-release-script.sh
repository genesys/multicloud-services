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
#             POSTGRES connection information and credentials
###############################################################################
export gvp_pg_db_server=$( get_secret gvp_pg_db_server )
export gvp_cm_pg_db_name=$( get_secret gvp_cm_pg_db_name )
export gvp_cm_pg_db_password=$( get_secret gvp_cm_pg_db_password )
export gvp_cm_pg_db_user=$( get_secret gvp_cm_pg_db_user )
###############################################################################
#             GVP credentials
###############################################################################
export gvp_cm_configserver_user=$( get_secret gvp_cm_configserver_user )
export gvp_cm_configserver_password=$( get_secret gvp_cm_configserver_password )
###############################################################################

###############################################################################
#             Secrets for GVP Configuration Server
#
# https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#Secrets_creation
###############################################################################
create_secret postgres-secret       db-hostname   $gvp_pg_db_server
create_secret postgres-secret       db-name       $gvp_cm_pg_db_name
create_secret postgres-secret       db-password   $gvp_cm_pg_db_password
create_secret postgres-secret       db-username   $gvp_cm_pg_db_user
create_secret configserver-secret   username      $gvp_cm_configserver_user
create_secret configserver-secret   password      $gvp_cm_configserver_password
###############################################################################