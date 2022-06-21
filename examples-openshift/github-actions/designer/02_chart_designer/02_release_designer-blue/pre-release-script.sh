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
# 			Gauth api credentials
###############################################################################
export designer_gws_client_id=$( get_secret designer_gws_client_id )
export designer_gws_client_secret=$( get_secret designer_gws_client_secret )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides designer_gws_client_id 		$designer_gws_client_id
replace_overrides designer_gws_client_secret 	$designer_gws_client_secret