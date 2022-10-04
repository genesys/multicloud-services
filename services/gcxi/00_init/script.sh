###############################################################################
# Attention: GCXI should be deployed after GIM and IWD because it relies on 
# deployment-secrets in corresponding namespaces
###############################################################################

######## Optional variables with defaults

[[ ! "$gcxi_db_host" ]] && export gcxi_db_host=$POSTGRES_RPTHIST_ADDR

[[ ! "$gcxi_gim_db_host" ]] && export gcxi_gim_db_host=$POSTGRES_RPTHIST_ADDR
[[ ! "$gcxi_gim_db_host" ]] && export gcxi_gim_db_host=$POSTGRES_ADDR
[[ ! "$gcxi_gim_db_name" ]] && export gcxi_gim_db_name=gim
[[ ! "$gcxi_gim_db_user" ]] && export gcxi_gim_db_user=gim
[[ ! "$gcxi_gim_db_pass" ]] && export gcxi_gim_db_pass=gim

[[ ! "$gcxi_iwd_db_host" ]] && export gcxi_iwd_db_host=$POSTGRES_DGT_ADDR
[[ ! "$gcxi_iwd_db_host" ]] && export gcxi_iwd_db_host=$POSTGRES_ADDR
[[ ! "$gcxi_iwd_db_name" ]] && export gcxi_iwd_db_name=iwddm-$TENANT_SID
[[ ! "$gcxi_iwd_db_user" ]] && export gcxi_iwd_db_user=iwddm-$TENANT_SID
[[ ! "$gcxi_iwd_db_pass" ]] && export gcxi_iwd_db_pass=iwddm-$TENANT_SID

# compatibility with older setups (eg. you can use GAUTH_CLIENT or gcxi_gws_client_id)
[[ "$gcxi_gws_client_id" ]] && export GAUTH_CLIENT=$gcxi_gws_client_id
[[ "$gcxi_gws_client_secret" ]]    && export GAUTH_KEY=$gcxi_gws_client_secret
[[ ! "$GAUTH_CLIENT" ]] && export GAUTH_CLIENT=gcxi_client
[[ ! "$GAUTH_KEY" ]]    && export GAUTH_KEY=secret

return 0