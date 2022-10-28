###############################################################################
# GSP requires object storage,
# such as Amazon S3, Azure Blob Storage, or Google Cloud Storage
# https://all.docs.genesys.com/PEC-REP/Current/GIMPEGuide/PlanningGSP
###############################################################################

###############################################################################
# For Openshift we suggest to use Noobaa operator
# https://cloud.redhat.com/blog/introducing-multi-cloud-object-gateway-for-openshift
# Create ObjectBucketClaim
if [[ "$CLUSTER_TYPE" == "openshift" ]] && [[ $COMMAND == "install" ]]; then
  print_log "creating/updating object bucket claim (Noobaa for Openshift)"
  envsubst < gim-gsp-obc.yaml | kubectl apply -f -
  sleep 5
  # and it automatically creates "gim" configmap and "gim" secret
fi

###############################################################################
# Otherwise, setup your object storage and bucket
# and define following variables in Deployment Secrets:
# - gsp_s3_bucket_host
# - gsp_s3_bucket_port
# - gsp_s3_bucket_name
# - gsp_s3_access_key
# - gsp_s3_secret_key
if [[ "$CLUSTER_TYPE" == "openshift" ]] || [[ "$CLUSTER_TYPE" == "gke" ]] && [[ $COMMAND == "install" ]]; then
# If following variables are NOT set in Deployment Secrets, 
# then we fetch them from local secret "gim" and configmap "gim" (created by Noobaa)
[[ ! "$gsp_s3_bucket_host" ]] && export gsp_s3_bucket_host=$(kubectl get cm gim -o jsonpath='{.data.BUCKET_HOST}')
[[ ! "$gsp_s3_bucket_port" ]] && export gsp_s3_bucket_port=$(kubectl get cm gim -o jsonpath='{.data.BUCKET_PORT}')
[[ ! "$gsp_s3_bucket_name" ]] && export gsp_s3_bucket_name=$(kubectl get cm gim -o jsonpath='{.data.BUCKET_NAME}')

[[ ! "$gsp_s3_access_key" ]]  && export gsp_s3_access_key=$(kubectl get secret gim -o yaml -o jsonpath={.data.AWS_ACCESS_KEY_ID} | base64 --decode)
[[ ! "$gsp_s3_secret_key" ]]  && export gsp_s3_secret_key=$(kubectl get secret gim -o yaml -o jsonpath={.data.AWS_SECRET_ACCESS_KEY} | base64 --decode)

[[ ! "$gsp_s3_bucket_host" ]] && [[ ! "$gsp_s3_access_key" ]] && [[ ! "$gsp_s3_secret_key" ]] && \
    error_exit "GSP requires S3 parameters through deployment secrets or Openshift object storage"

# If S3 parameters are provided via depl secrets and not via ObjectBucketClaim,
# create secret and configmap "gim" (so that GCA can fetch it during deployment)
if ! kubectl get cm gim 2>/dev/null; then
    kubectl create cm gim \
      --from-literal=BUCKET_HOST=$gsp_s3_bucket_host \
      --from-literal=BUCKET_NAME=$gsp_s3_bucket_name \
      --from-literal=BUCKET_PORT=$gsp_s3_bucket_port \
      --dry-run=client -o yaml | kubectl apply -f -
fi
if ! kubectl get secret gim 2>/dev/null; then
    kubectl create secret generic gim \
      --from-literal=AWS_ACCESS_KEY_ID=$gsp_s3_access_key \
      --from-literal=AWS_SECRET_ACCESS_KEY=$gsp_s3_secret_key \
      --dry-run=client -o yaml | kubectl apply -f -
fi
fi