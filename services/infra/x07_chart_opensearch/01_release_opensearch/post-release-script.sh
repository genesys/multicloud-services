### uncomment if required
#[[ "$CLUSTER_TYPE" == "openshift" ]] && \
#	oc adm policy add-scc-to-user privileged -z opensearch -n $NS