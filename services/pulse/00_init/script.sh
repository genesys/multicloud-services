###############################################################################
#	Pulse (pulse) is deployed per-tenant
#	https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide/ArchitectureMain
###############################################################################

# TENANT_SID and TENANT_UUID (as well as other Postgre and Redis-related variables) 
# are supposed to be already defined via Deployment Secrets (DS)

######## Mandatory variables

[[ ! "$pulse_gws_client_id" ]]     && export pulse_gws_client_id="pulse_client"
[[ ! "$pulse_gws_client_secret" ]] && error_exit "provide pulse_gws_client_secret via deployment secrets"

######## Optional variables with defaults

# We will be using Postgres instance $POSTGRES_RPT_ADDR (defined via DS)
[[ ! "$POSTGRES_RPTRT_ADDR" ]]    && export POSTGRES_ADDR=$POSTGRES_RPTRT_ADDR
[[ ! "$pulse_db_name" ]]          && export pulse_db_name="pulse"
[[ ! "$pulse_db_user" ]]          && export pulse_db_user="pulse"
[[ ! "$pulse_db_password" ]]      && export pulse_db_password="pulse"

[[ ! "$pulse_redis_host" ]] && export pulse_redis_host=pulse-redis-master
[[ ! "$pulse_redis_port" ]] && export pulse_redis_port=6379
[[ ! "$pulse_redis_key" ]]  && export pulse_redis_key=secret

###############################################################################
# Create pulse DB if it does not exist
###############################################################################
create_pg_db $pulse_db_name $pulse_db_user $pulse_db_password
