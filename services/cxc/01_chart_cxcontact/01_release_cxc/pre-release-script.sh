# Optional variables with defaults

[[ "$POSTGRES_STD_ADDR" ]]    && export POSTGRES_ADDR=$POSTGRES_STD_ADDR
[[ ! "$cxc_redis_password" ]] && export cxc_redis_password=$REDIS_PASSWORD


############ IMPORTANT for Openshift ############
# Like with Designer, CXC requires mount options with "uid=<arb_uid>" in storage class
# where arb_uid is arbitrary UID assigned by Openshift to pods in this namepace
# Need also enforce this UID in securityContext.runAsUser further
if [[ "$CLUSTER_TYPE" == "openshift" ]]; then
    export ARB_UID=$(oc describe project $NS| grep 'sa.scc.uid-range'| cut -d'=' -f2| cut -d'/' -f1)
    envsubst < storage_class_openshift.yaml | kubectl apply -f -
fi