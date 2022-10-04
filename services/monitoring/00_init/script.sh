# Openshift defines arbitrary UID range for pods in namespace
# and does not allow to run with UIDs outside of allowed range.

# Most of deployed 3rd party services allow to configure it in Helm overrides.
# But some infra services may still have problems with persistent storages.
# This is workaround for such services (using service account infra-sa):

if [ "$CLUSTER_TYPE" == "openshift" ]; then
    if ! oc get sa monitoring-sa; then
        oc create sa monitoring-sa
    fi
    oc adm policy add-scc-to-user anyuid -z monitoring-sa -n $NS || true

    # Use storage account specific to this project/namespace
    export ARB_UID=$(oc describe project $NS| grep 'sa.scc.uid-range'| cut -d'=' -f2| cut -d'/' -f1)
    envsubst < storage_class_openshift.yaml | kubectl apply -f -
fi

return 0