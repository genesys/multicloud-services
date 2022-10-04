( ! wait_running_status "service=${SERVICE}" 600 ) && error_exit "pods are not ready"

echo ##############################
echo "Installing GAUTH Admin Client"
echo ##############################
source ./misc_apiclient.sh add external_api_client

# echo ##############################
# echo "Installing CCID"
# echo ##############################
# source ./misc_ccid.sh ccid 100 $LOCATION $DOMAIN