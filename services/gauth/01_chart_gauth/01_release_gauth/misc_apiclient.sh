# This is to show|add|update|delete API client

# INPUT_COMMAND shoulbe like "[show|add|update|delete] <client_id> <domain>"
# three words separated by space:
#   #1 - show, add, update (redirectURIs list), delete
#   #2 - client_id (ex: gcxi_client) or "all" keyword 
#   #3 - domain ex cluster03.gcp.demo.genesys.com

# 🖊️ EDIT for your needs
#    API clients list for bulk operation ("all")
CLIENTS=(external_api_client)

ACT=$1
CLN=$2
[[ "$3" ]] && domain=$3 || domain=$DOMAIN

echo "Action: $ACT"
echo "Clients: $CLN"
echo "Domain: $domain"

# Redirect URIs allowed for these clients (redirections during SSO auth)
REDIRECT_URIS=$(cat << EOF
"https://gauth.$domain",
"https://gws.$domain",
"https://wwe.$domain"
EOF
)

###++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# These should be already known from depl secrets:
# - gauth_admin_username
# - gauth_admin_password_plain

CREDS="'$gauth_admin_username:$gauth_admin_password_plain'"
[[ "$ACT" != "show" && "$ACT" != "add" && "$ACT" != "update" && "$ACT" != "delete" ]] && error_exit "command must be like '[add|update|delete] <client_id>'"
[[ "$CLN" == "" ]] && error_exit "need client ID"
[[ "$CLN" != "all" ]] && CLIENTS=($CLN)

# We will Curl from gauth pod, because there may be no access from GH runner to ingress https://gauth.$domain
GAPOD=$(kubectl get po | grep gauth-auth | grep Running | grep -v gauth-auth-ui -m1 | awk '{print $1}')
echo $GAPOD

echo "*** Pre-change list of clients:"
#curl -skL https://gauth.$domain/auth/v3/ops/clients .. - via ingress
kubectl exec $GAPOD --container gauth \
    -- bash -c "curl -s http://gauth-auth/auth/v3/ops/clients -u $CREDS" \
    | jq .data[].client_id || true


###++++++++ Show all settings except secrets and keys, for certain api client ++
if [ "$ACT" == "show" ]; then
    if [ "$CLN" == "all" ]; then
        echo "*** Pre-change, all existing clients:"
        kubectl exec $GAPOD --container gauth \
            -- bash -c "curl -s http://gauth-auth/auth/v3/ops/clients -u $CREDS" | tee RSP
        [[ "$(cat RSP | jq .status.code)" != "0" ]] \
            && error_exit "Clients list not found? Failed http request to Gauth: $(cat RSP | jq .status)"
        cat RSP | jq .data[]
    else
        echo "*** Pre-change client $CLN properties:"
        kubectl exec $GAPOD --container gauth \
            -- bash -c "curl -s http://gauth-auth/auth/v3/ops/clients/$CLN -u $CREDS" | tee RSP
        [[ "$(cat RSP | jq .status.code)" != "0" ]] \
            && error_exit "Client not found? Failed http request to Gauth: $(cat RSP | jq .status)"
        cat RSP | jq .data[]
    fi
    return 0
fi

#################################
# Check if Client exists
#################################
kubectl exec $GAPOD --container gauth \
    -- bash -c "curl -s http://gauth-auth/auth/v3/ops/clients/$CLN -u $CREDS" | tee RSP
RSP=$(cat RSP | jq .data.client_id | tr -d '"')
echo "Response: $RSP"
if [[ $RSP == $CLN ]]; then
  echo "Auth Client Exists... updating it" && ACT="update"
  echo "Current Action: $ACT"
else
  echo "Auth Client Does Not Exist... adding it"
fi 

###+++++++++++++ Add new api client (will return error if already exists) ++++++
if [ "$ACT" == "add" ]; then

    #################################################################
    ###                 ADJUST LIST OF redirectURIs              ####
    #################################################################

NEW_API_CLIENT()
{
  cat <<EOF
  { "data":
        {  "redirectURIs": [
              $REDIRECT_URIS
           ],
           "client_id":"$1",
           "name":"$1",
           "description":"$1",
           "client_secret": "secret",

           "refreshTokenExpirationTimeout":2592000,
           "clientType":"CONFIDENTIAL",
           "internalClient":true,
           "authorizedGrantTypes":[
              "refresh_token", "implicit", "client_credentials", "password", "authorization_code",
              "urn:ietf:params:oauth:grant-type:token-exchange", "urn:ietf:params:oauth:grant-type:jwt-bearer"
           ],
           "authorities":["ROLE_INTERNAL_CLIENT","ROLE_MANAGEMENT_APPLICATION"],
           "accessTokenExpirationTimeout":43200,
           "scope":["*"]
        }
  }
EOF
}

    # can also bind client to environment, adding like:
    #   "contactCenterIds": [
    #     "9350e2fc-a1dd-4c65-8d40-1f75a2e080dd"
    #   ],

    for cl in ${CLIENTS[*]}
    do
        echo "____________________ Adding apiclient: $cl __________________________________"
        kubectl exec $GAPOD --container gauth \
            -- bash -c "curl -s -XPOST http://gauth-auth/auth/v3/ops/clients -u $CREDS \
            -H 'Content-Type: application/json' -d '$(NEW_API_CLIENT $cl)'" | tee RSP
        sleep 5
        echo;echo "_________________________________________________________________________"
    done
fi


###++++++++++++++++++++++++++++++ Delete api client ++++++++++++++++++++++++++++
if [ "$ACT" == "delete" ]; then
    for cl in ${CLIENTS[*]};
    do
        echo "____________________ Deleting apiclient: $cl __________________________________"
        kubectl exec $GAPOD --container gauth \
            -- bash -c "curl -s -XDELETE http://gauth-auth/auth/v3/ops/clients/$cl -u $CREDS" | tee RSP
        echo;echo "________________________________________________________________________________"
    done
fi


###++++++++++++++++++++++ Update list of redirect URIs only ++++++++++++++++++++
if [ "$ACT" == "update" ]; then

     #################################################################
     ###                 ADJUST LIST OF redirectURIs              ####
     #################################################################

NEW_REDURI()
{
  cat <<EOF
  { "data":
       {"redirectURIs": [
            $REDIRECT_URIS
        ]
      }
  }
EOF
}

    for cl in ${CLIENTS[*]};do
        echo "____________________ Updating apiclient: $cl __________________________________"
        kubectl exec $GAPOD --container gauth \
            -- bash -c "curl -s -XPUT http://gauth-auth/auth/v3/ops/clients/$cl -u $CREDS \
            -H 'Content-Type: application/json' -d '$(NEW_REDURI)'" | tee RSP
        echo;echo "_____________________________________________________________________________"
    done
fi

###+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


[[ "$(cat RSP | jq .status.code)" != "0" && "$CLN" != "all" ]] && \
    error_exit "failed http request to Gauth: $(cat RSP | jq .status)"


echo "*** Post-change, current list of cients:"
kubectl exec $GAPOD --container gauth \
    -- bash -c "curl -s http://gauth-auth/auth/v3/ops/clients -u $CREDS" | jq .data[].client_id