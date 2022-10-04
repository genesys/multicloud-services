###############################################################################
# Attention: GSXI-RAA should be deployed after GIM because it relies on 
# deployment-secrets in corresponding namespace!
###############################################################################


###############################################################################
#      GCXI_GIM_DB__JSON
###############################################################################
export GCXI_GIM_DB__JSON=$(cat <<EOF | jq -c | base64 -w 0
{
  "jdbc_url":"jdbc:postgresql://${gcxi_gim_db_host}:${POSTGRES_PORT}/${gcxi_gim_db_name}",
  "db_username":"${gcxi_gim_db_user}",
  "db_password":"${gcxi_gim_db_pass}"
}
EOF
)
