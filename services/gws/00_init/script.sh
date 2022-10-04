########### Mandatory variables

[[ ! "$gws_client_secret" ]]    && error_exit "need GWS auth client id & secret, provided via deployment secrets"
[[ ! "$gws_app_provisioning" ]] && error_exit "need gws_app_provisioning in deployment secrets"
[[ ! "$gws_app_workspace" ]]    && error_exit "need gws_app_workspace in deployment secrets"


######## Optional variables with defaults

# Using Postgres instance dedicated to GWS services
# Otherwise use standard default instance
[[ "$POSTGRES_GWS_ADDR" ]] && export POSTGRES_ADDR="$POSTGRES_GWS_ADDR"

[[ ! "$gws_consul_token" ]] && export gws_consul_token=$CONSUL_BOOT_TOKEN
[[ ! "$gws_consul_token" ]] && error_exit "need gws_consul_token or CONSUL_BOOT_TOKEN in deployment secrets"

[[ "$gws_redis_password" ]] && export REDIS_PASSWORD="$gws_redis_password"

[[ ! "$gws_client_id" ]]    && export gws_client_id="$auth_client_gws"
[[ ! "$wrkspc_client_id" ]] && export wrkspc_client_id="$auth_client_gws_ws"
[[ ! "$prov_client_id" ]]   && export prov_client_id="$auth_client_gws_prov"

# Default DB name/user/pass for GWS and Provisioning
[[ ! "$gws_pg_dbname" ]] && export gws_pg_dbname=gws
[[ ! "$gws_pg_user" ]]   && export gws_pg_user=gws
[[ ! "$gws_pg_pass" ]]   && export gws_pg_pass=gws

[[ ! "$gws_pg_dbname_prov" ]] && export gws_pg_dbname_prov=prov
[[ ! "$gws_as_pg_user" ]]   && export gws_as_pg_user=prov
[[ ! "$gws_as_pg_pass" ]]   && export gws_as_pg_pass=prov

[[ ! "$gws_ops_user" ]]   && export gws_ops_user=ops
[[ ! "$gws_ops_pass" ]]   && export gws_ops_pass=ops
[[ ! "$gws_ops_pass_encr" ]] && export gws_ops_pass_encr='$2a$10$GQTt0EfpwGva.0dj5YiRUOvDEL40Eh.iC8tbfK0r7LygRGAgaPyVm'


###############################################################################
# Creating GWS DB if not exist and init
###############################################################################
envsubst < init_db.sh > init_db.sh_
kubectl delete pods busybox || true
kubectl run busybox --image=alpine --restart=Never -- sh -c "$(<init_db.sh_)"
sleep 10
kubectl delete pods busybox || true