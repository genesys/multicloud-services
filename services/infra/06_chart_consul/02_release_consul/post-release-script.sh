## as workaround we grant consul-xx security accounts a privileged scc

for i in $(kubectl get sa| grep ^consul| awk '{print $1}')
do
    oc adm policy add-scc-to-user privileged -z $i -n $NS || true
done

print_log "wait for readiness of Consul server nodes"
kubectl rollout status sts consul-server --timeout=2m

# update cluster DNS (forwarding to consul zone)
consul_update_dns

# allow connectivity via Consul service mesh 
# (obtain bootstrap token first, as it's not in deployment secrets yet)
CONSUL_BOOT_TOKEN=$(get_secret consul-bootstrap-acl-token token)
create_consul_intention

return 0