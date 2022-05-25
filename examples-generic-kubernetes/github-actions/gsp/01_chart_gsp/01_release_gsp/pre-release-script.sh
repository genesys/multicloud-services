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

###############################################################################
#       GCloud SA credentials
###############################################################################
export S3_ACCESS_KEY=$( get_secret S3_ACCESS_KEY )
export S3_SECRET=$( get_secret S3_SECRET )
###############################################################################