###############################################################################
# Postgres related defaults
###############################################################################
[[ "$POSTGRES_UCSX_ADDR" ]] && export POSTGRES_ADDR=$POSTGRES_UCSX_ADDR

# if there is special ES instance for UCSX, us it
[[ "$ES_ADDR_UCSX" ]] && export ES_ADDR=$ES_ADDR_UCSX

[[ ! "$ucsx_db_name" ]] && export ucsx_db_name="ucsx"

tdbname="ucsx_tenant_${TENANT_SID}_db_name"
tdbuser="ucsx_tenant_${TENANT_SID}_db_user"
tdbpass="ucsx_tenant_${TENANT_SID}_db_password"

[[ "${!tdbname}" ]] && export ucsx_tenant_db_name=${!tdbname} || export ucsx_tenant_db_name="ucsx_t100"
[[ "${!tdbuser}" ]] && export ucsx_tenant_db_user=${!tdbuser} || export ucsx_tenant_db_user="ucsx_t100"
[[ "${!tdbpass}" ]] && export ucsx_tenant_db_password=${!tdbpass} || export ucsx_tenant_db_password="ucsx"

# if there is special ES instance for UCSX, us it
if kubectl get svc ucsx-elastic-es-http -n infra; then
    export ES_ADDR=ucsx-elastic-es-http.infra
fi

###############################################################################
# Creating UCSX DB if not exist and init
###############################################################################
envsubst < create_ucsx_db.sh > create_ucsx_db.sh_
kubectl run busybox -i --rm --image=alpine --restart=Never -- sh -c "$(<create_ucsx_db.sh_)"
