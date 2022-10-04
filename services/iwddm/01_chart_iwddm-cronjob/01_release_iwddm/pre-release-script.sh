######## Mandatory variables

# API key like "iWD 100 t100 IWDDM Key" from Nexus DB, nex_apikeys table
[[ ! "$iwddm_nexus_api_key" ]] && error_exit "provide iwddm_nexus_api_key via deployment secrets"

######## Optional variables with defaults

# For iWDDM we will be using Postgre instance $POSTGRES_DGT_ADDR (defined via DS)

[[ "$POSTGRES_DGT_ADDR" ]] && export POSTGRES_ADDR=$POSTGRES_DGT_ADDR

# iwddm_db_user --> IWDDM_USER --> iwddm-$TENANT_SID
[[ "$iwddm_db_user" ]] && export IWDDM_USER=$iwddm_db_user
[[ ! "$IWDDM_USER" ]]  && export IWDDM_USER=iwddm-$TENANT_SID

# iwddm_db_password --> IWDDM_PASSWORD --> iwddm-$TENANT_SID
[[ "$iwddm_db_password" ]] && export IWDDM_PASSWORD="$iwddm_db_password"
[[ ! "$IWDDM_PASSWORD" ]]  && export IWDDM_PASSWORD=iwddm-$TENANT_SID

# iwddm_gim_db_addr --> gim_db_addr --> POSTGRES_RPTHIST_ADDR
[[ "$iwddm_gim_db_addr" ]] && export gim_db_addr=$iwddm_gim_db_addr
[[ ! "$gim_db_addr" ]] && export gim_db_addr=$POSTGRES_RPTHIST_ADDR

# iwddm_gim_db_name --> gim_db_name --> gim
[[ "$iwddm_gim_db_name" ]] && export gim_db_name=$iwddm_gim_db_name
[[ ! "$gim_db_name" ]] && export gim_db_name=gim

# iwddm_gim_db_user --> gim_db_user --> gim
[[ "$iwddm_gim_db_user" ]] && export gim_db_user=$iwddm_gim_db_user
[[ ! "$gim_db_user" ]] && export gim_db_user=gim

# iwddm_gim_db_password --> gim_db_password --> gim
[[ "$iwddm_gim_db_password" ]] && export gim_db_password="$iwddm_gim_db_password"
[[ ! "$gim_db_password" ]] && export gim_db_password=gim

###############################################################################
# Provisioning secrets:
# https://all.docs.genesys.com/PEC-IWD/Current/IWDDMPEGuide/Configure#Secrets
###############################################################################
kubectl create secret generic iwd-secrets-${TENANT_SID} --dry-run=client -o yaml \
		--from-literal="IWDDM_API_KEY=${iwddm_nexus_api_key}" | kubectl apply -f -

cat <<EOF > gim-secret.txt
IWDDM_GIM_DBUSER=$gim_db_user
IWDDM_GIM_PASSWORD=$gim_db_password
IWDDM_GIM_URL=jdbc:postgresql://${gim_db_addr}:5432/$gim_db_name
EOF
kubectl create secret generic gim-secrets-${TENANT_SID} \
		--from-file=gim-secret.txt --dry-run=client -o yaml | kubectl apply -f -


##############################################################################
# Creating IWDDM DB and user if not exists
###############################################################################
create_pg_db iwddm-$TENANT_SID "$IWDDM_USER" "$IWDDM_PASSWORD"
