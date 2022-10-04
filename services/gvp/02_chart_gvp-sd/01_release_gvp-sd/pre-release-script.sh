# These variables, if not defined in your deployment secrets,
# will be taken from global defaults:
[[ ! "$gvp_consul_token" ]] && export gvp_consul_token=$CONSUL_BOOT_TOKEN

[[ ! "$TENANT_SID" ]]  && export TENANT_SID="100"
[[ ! "$TENANT_UUID" ]] && export TENANT_UUID="9350e2fc-a1dd-4c65-8d40-1f75a2e080dd"
# last 4 chars of UUID
export TID=$(echo $TENANT_UUID| rev| cut -c 1-4| rev)

#################################################################################
#   Secret for GVP Service Discovery
#   https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#Secrets_creation_2
#################################################################################
kubectl create secret generic shared-consul-consul-gvp-token \
  --from-literal=consul-consul-gvp-token=$gvp_consul_token \
  --dry-run=client -o yaml | kubectl apply -f -

#################################################################################
#   ConfigMap for GVP Service Discovery
#   https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#ConfigMap_creation
#################################################################################

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: tenant-inventory
data:
  t100.json: |
    {
        "name": "t$TENANT_SID",
        "id": "$TID",
        "gws-ccid": "$TENANT_UUID",
        "default-application": "IVRAppDefault",
        "provisioned": "true"
    }
EOF
