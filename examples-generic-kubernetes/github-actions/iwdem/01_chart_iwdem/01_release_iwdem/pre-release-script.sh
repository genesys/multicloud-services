###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
# 								Using it! 
# We extract secrets to environment variables. It will evaluate variables in
# override values by workflow.
###############################################################################
function get_secret {
	# Using: get_secret secret_name
	echo $( kubectl get secrets deployment-secrets -o custom-columns=:data.$1 \
			--no-headers | base64 -d )
}

function replace_overrides {
  # Using: replace_overrides old_value new_value
  ESCAPED_S=$(printf '%s' "$2" | sed -e 's/[\/&]/\\&/g')
  cat override_values.yaml | sed "s/$1/$ESCAPED_S/g" > override_values.tmp \
     && mv override_values.tmp override_values.yaml 
}

###############################################################################
# 			Redis password
###############################################################################
export iwdem_redis_password=$( get_secret iwdem_redis_password )
###############################################################################
# 			Nexus api key
###############################################################################
export iwdem_nexus_api_key=$( get_secret iwdem_nexus_api_key )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides iwdem_redis_password 		$iwdem_redis_password
replace_overrides iwdem_nexus_api_key 		$iwdem_nexus_api_key