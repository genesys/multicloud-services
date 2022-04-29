function replace_overrides {
  # Using: replace_overrides old_value new_value
  ESCAPED_S=$(printf '%s' "$2" | sed -e 's/[\/&]/\\&/g')
  cat override_values.yaml | sed "s/$1/$ESCAPED_S/g" > override_values.tmp \
     && mv override_values.tmp override_values.yaml 
}

###############################################################################
#       Creating Object Bucket Claim
#
# https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.6/html/managing_hybrid_and_multicloud_resources/object-bucket-claim
###############################################################################
cat <<EOF | kubectl apply -f -
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: gim
spec:
  generateBucketName: gim
  storageClassName: openshift-storage.noobaa.io
EOF
sleep 5
###############################################################################
# Automaticaly have to be created: 
#     config-map: gim
#     secret: gim
# Reading it...
###############################################################################
bucket_name=$(kubectl get cm gim -o jsonpath='{.data.BUCKET_NAME}')
bucket_host=$(kubectl get cm gim -o jsonpath='{.data.BUCKET_HOST}')
bucket_port=$(kubectl get cm gim -o jsonpath='{.data.BUCKET_PORT}')
export s3_access_key=$(kubectl get secret gim -o yaml -o jsonpath={.data.AWS_ACCESS_KEY_ID} | base64 --decode)
export s3_secret_key=$(kubectl get secret gim -o yaml -o jsonpath={.data.AWS_SECRET_ACCESS_KEY} | base64 --decode)
export s3_endpoint="https://$bucket_host:$bucket_port"
export gsp_prefix="s3p://$bucket_name/{{ .Release.Name }}/"
export gca_snapshots="s3p://$bucket_name/gca/"
###############################################################################

# For validation process need to evaluate release override values here
replace_overrides s3_access_key     $s3_access_key
replace_overrides s3_secret_key     $s3_secret_key
replace_overrides s3_endpoint       $s3_endpoint
replace_overrides gsp_prefix        "$gsp_prefix"
replace_overrides gca_snapshots     $gca_snapshots