###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
#                 Using it! 
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
#       GCloud SA credentials
###############################################################################
export S3_ACCESS_KEY=$( get_secret ACCESS_KEY_ID )
export S3_SECRET_KEY=$( get_secret SECRET_ACCESS_KEY )
###############################################################################
#       Storage bucket details
###############################################################################
export BUCKET_HOST=$( get_secret BUCKET_HOST )
export BUCKET_NAME=$( get_secret BUCKET_NAME )
export BUCKET_PORT=$( get_secret BUCKET_PORT )
###############################################################################
#       Storage bucket details
###############################################################################
export KAFKA_ADDR=$( get_secret KAFKA_ADDR )
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides S3_ACCESS_KEY 		$S3_ACCESS_KEY
replace_overrides S3_SECRET_KEY 		$S3_SECRET_KEY
replace_overrides BUCKET_HOST 			$BUCKET_HOST
replace_overrides BUCKET_NAME 			$BUCKET_NAME
replace_overrides BUCKET_PORT 			$BUCKET_PORT
replace_overrides KAFKA_ADDR 		    $KAFKA_ADDR
