######## Mandatory variables

[[ ! "$nexus_gws_client_id" ]] || [[ ! "$nexus_gws_client_secret" ]] && \
    error_exit "need Nexus auth client id & secret, provided via deployment secrets"

######## Optional variables with defaults

# Using Postgres instance dedicated to Digital services
# Otherwise use standard default instance
[[ "$POSTGRES_DGT_ADDR" ]] && export POSTGRES_ADDR="$POSTGRES_DGT_ADDR"

# Defaults for Nexus DB creds (recommended to change via deployment secrets)
[[ ! "$nexus_db_user" ]] && export nexus_db_user=nexus
[[ ! "$nexus_db_password" ]] && export nexus_db_password=nexus

# Default tenant's admin credentials, for Nexus provisioning
[[ ! "$nexus_tenant_adm_user" ]] && export nexus_tenant_adm_user=default
[[ ! "$nexus_tenant_adm_pass" ]] && export nexus_tenant_adm_pass=password

##############################################################################
# Creating Nexus DB if not exist and init
###############################################################################
create_pg_db nexus $nexus_db_user $nexus_db_password
