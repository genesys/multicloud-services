###############################################################################                
# See README file or official documentation:
# https://all.docs.genesys.com/BDS/Current/BDSPEGuide/Provision#OpenShift
###############################################################################

[[ "$POSTGRES_RPTHIST_ADDR" ]] && export POSTGRES_ADDR="$POSTGRES_RPTHIST_ADDR"

[[ ! "$bds_gws_client_id" ]]     && export bds_gws_client_id=$tenant_gws_client_id
[[ ! "$bds_gws_client_secret" ]] && export bds_gws_client_secret=$tenant_gws_client_secret

[[ ! "$bds_gws_client_id" ]]     && error_exit "need bds_gws_client_id in deployment secrets"
[[ ! "$bds_gws_client_secret" ]] && error_exit "need bds_gws_client_secret in deployment secrets"

[[ ! "$bds_sftp_host" || ! "$bds_sftp_path" || ! "$bds_sftp_user" || ! "$bds_sftp_pass" ]] && \
    error_exit "need SFTP server info in deployment secrets"

###############################################################################
# Create ServiceAccount, if not exists
###############################################################################
! (kubectl get sa genesys > /dev/null 2>&1)  && kubectl create sa genesys && \
    print_log "SA genesys has been created"

###############################################################################
# Create PVC, if not exists
###############################################################################
envsubst < bds-pvc.yaml > bds-pvc.yaml_
! (kubectl get pvc bds-pvc > /dev/null 2>&1) && kubectl create -f bds-pvc.yaml_ && \
    print_log "PVC bds-pvc has been created"

###############################################################################
# Create or update manual secret
###############################################################################
envsubst < bds-manual-secrets.yaml | kubectl apply -f -
print_log "Manual BDS secret has been created/updated"

return 0