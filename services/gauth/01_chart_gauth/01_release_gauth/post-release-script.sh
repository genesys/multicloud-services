( ! wait_running_status "service=${SERVICE}" 600 ) && error_exit "pods are not ready"

echo ##############################
echo "Installing GAUTH Admin Client"
echo ##############################
source ./gauth_apiclient.sh add ${gauth_gws_client_id}
