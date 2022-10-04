# These variables, if not defined in your deployment secrets,
# will be taken from global defaults:
[[ ! "$gvp_pg_db_server" ]]      && export gvp_pg_db_server=$POSTGRES_STD_ADDR
[[ ! "$gvp_cm_pg_db_name" ]]     && export gvp_cm_pg_db_name="gvp"
[[ ! "$gvp_cm_pg_db_user" ]]     && export gvp_cm_pg_db_user=$POSTGRES_USER
[[ ! "$gvp_cm_pg_db_password" ]] && export gvp_cm_pg_db_password="$POSTGRES_PASSWORD"

# Create Postgres DB for GVP configserver
create_pg_db $gvp_cm_pg_db_name $gvp_cm_pg_db_user $gvp_cm_pg_db_password $gvp_pg_db_server


###############################################################################
#   Create secrets for GVP Config Server
###############################################################################
kubectl create secret generic postgres-secret \
  --from-literal=db-hostname=$gvp_pg_db_server \
  --from-literal=db-name=$gvp_cm_pg_db_name \
  --from-literal=db-password=$gvp_cm_pg_db_password \
  --from-literal=db-username=$gvp_cm_pg_db_user \
  --from-literal=server-name=$gvp_pg_db_server \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic configserver-secret \
  --from-literal=username=$gvp_cm_configserver_user \
  --from-literal=password=$gvp_cm_configserver_password \
  --dry-run=client -o yaml | kubectl apply -f -
