# post-release actions

if [ "$CLUSTER_TYPE" == "openshift" ]   # for Openshift only
then
	print_log "Adding necessary rights to promtail SA"

    #oc adm policy add-scc-to-user hostmount-anyuid -z loki-stack-promtail -n $NS
    #oc adm policy add-scc-to-user privileged -z loki-stack-promtail -n $NS
    envsubst < scc_promtail_permissions.yaml | oc apply -f -
fi

# readiness check
kubectl rollout status ds loki-stack-promtail --timeout=2m
kubectl rollout status sts loki-stack --timeout=4m
