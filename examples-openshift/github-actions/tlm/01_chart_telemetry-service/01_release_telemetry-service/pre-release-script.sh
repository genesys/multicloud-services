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

###############################################################################
# 			Gauth api credentials
###############################################################################
export TELEMETRY_AUTH_CLIENT_ID=$( get_secret TELEMETRY_AUTH_CLIENT_ID )
export TELEMETRY_AUTH_CLIENT_SECRET=$( get_secret TELEMETRY_AUTH_CLIENT_SECRET )
###############################################################################