###############################################################################
# Attention: GSXI-RAA should be deployed after GIM because it relies on 
# deployment-secrets in corresponding namespace!
###############################################################################
function get_secret {
	# Using: get_secret secret_name [namespace secret-name]
  ds=${3:-deployment-secrets}
  ns=$NS
  [ "$2" ] && ns=$2
	echo $( kubectl -n $ns get secrets $ds -o custom-columns=:data.$1 \
			--no-headers | base64 -d )
}

function replace_overrides {
  # Using: replace_overrides old_value new_value
  ESCAPED_S=$(printf '%s' "$2" | sed -e 's/[\/&]/\\&/g')
  cat override_values.yaml | sed "s/$1/$ESCAPED_S/g" > override_values.tmp \
     && mv override_values.tmp override_values.yaml 
}

###############################################################################
#       GIM database parameters from GIM deployment secrets
###############################################################################
export gim_db_name=$( get_secret gim_db_name )
export gim_db_user=$( get_secret gim_db_user )
export gim_db_pass=$( get_secret gim_db_pass )
###############################################################################
#           Postgres address
###############################################################################
export POSTGRES_ADDR=$( get_secret gim_db_host )
###############################################################################
#      GCXI_GIM_DB__JSON
###############################################################################
GCXI_GIM_DB__JSON=$(cat <<EOF | jq -c | base64 -w 0
{
  "jdbc_url":"jdbc:postgresql://${POSTGRES_ADDR}:5432/${gim_db_name}",
  "db_username":"${gim_db_user}",
  "db_password":"${gim_db_pass}"
}
EOF
)
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides {GCXI_GIM_DB__JSON}  $GCXI_GIM_DB__JSON
