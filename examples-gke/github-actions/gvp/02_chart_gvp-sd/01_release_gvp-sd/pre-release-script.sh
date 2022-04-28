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
#             CONSUL credentials
###############################################################################
export gvp_consul_token=$( get_secret gvp_consul_token )
###############################################################################


###############################################################################
#             Secrets for GVP Configuration Server
#
# https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#Secrets_creation_2
###############################################################################
create_secret shared-consul-consul-gvp-token consul-consul-gvp-token $gvp_consul_token
###############################################################################

###############################################################################
#             ConfigMap for GVP Configuration Server
#
# https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#ConfigMap_creation
###############################################################################
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: tenant-inventory
data:
  t100.json: |
    {
        "name": "t100",
        "id": "80dd",
        "gws-ccid": "9350e2fc-a1dd-4c65-8d40-1f75a2e080dd",
        "default-application": "IVRAppDefault",
        "provisioned": "true"
    }
EOF
###############################################################################