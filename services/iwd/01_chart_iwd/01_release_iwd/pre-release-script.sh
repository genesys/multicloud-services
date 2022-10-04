### Mandatory variables

[[ ! "$iwd_gws_client_id" ]] || [[ ! "$iwd_gws_client_secret" ]] && \
    error_exit "iWD auth client id & secret, provided via deployment secrets"

[[ ! "$iwd_nexus_api_key" ]]        || [[ ! "$iwd_tenant_api_key" ]]        || \
[[ ! "$iwd_tenant_api_key_iwddm" ]] || [[ ! "$iwd_tenant_api_key_tenant" ]] && \
    error_exit "iWD requires API keys, provided via deployment secrets"

######## Optional variables with defaults

# Using Postgres instance dedicated to Digital services
# Otherwise use standard default instance
[[ "$POSTGRES_DGT_ADDR" ]] && export POSTGRES_ADDR="$POSTGRES_DGT_ADDR"

# Defaults for IWD DB creds (recommended to change via deployment secrets)
[[ ! "$iwd_db_name" ]] && export iwd_db_name="iwd-$TENANT_SID"
[[ ! "$iwd_db_user" ]] && export iwd_db_user="iwd-$TENANT_SID"
[[ ! "$iwd_db_password" ]] && export iwd_db_password="iwd-$TENANT_SID"


###############################################################################
# Use existing Nexus API keys (iWD cluster key and master key for Tenant)
# In nexus db: SELECT id,name FROM nex_apikeys
# Example:
#                   id                  |          name           
# --------------------------------------+-------------------------
#  76e620e4-2691-4674-abcd-2b1711405d2c | Cluster API Key
#  96b0802b-799f-4f55-abcd-ba51eadf75df | iWD Cluster API Key  <-- iwd_nexus_api_key
#  f34879ce-e945-4ddc-abcd-d70b7815901a | Portico Cluster API Key
#  2562992b-8b70-48e3-abcd-b1a8f2676852 | CXContact API Key
#  86bcbc3c-0cbd-4b57-abcd-299182462079 | t100                <-- iwd_tenant_api_key
#  27a6d0c4-f5db-4a18-abcd-e3a97cb460d1 | t100-Designer
#  049111b4-6cac-4e83-abcd-37c057b45b0f | t100-iWD

###############################################################################
# Generate new UUIDs for apikeys for tenant and iwddm:
# $ echo  "$(uuidgen)" | tr '[:upper:]' '[:lower:]')
#     --> iwd_tenant_api_key_iwddm
#     --> iwd_tenant_api_key_tenant
###############################################################################



##############################################################################
# Creating IWD DB if not exists
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"
