# Note: this is UCSX provisioning for tenant
# It will fail if you run it over existing provisioned UCSX
# You can check if helm release like "ucsx-addtenant-100-register" already installed
# If installed, we will skip provisioning
if helm status ucsx-addtenant-${TENANT_SID}-register; then
    print_log "UCSX looks to be already provisioned for tenant ${TENANT_SID}. Skipping provisioning"
    RELEASE=""
    return 0
fi

###############################################################################
# Creating UCSX DB if not exist and init
###############################################################################
envsubst < create_ucsx_tenant_db.sh > create_ucsx_tenant_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<create_ucsx_tenant_db.sh_)"