## This release is only for k8s >= 1.22

print_log "Checking k8s version: $(get_k8s_version)"

if [[ $(get_k8s_version | awk '{if ($1 < 1.22) print 1}') == "1" ]]
then
	print_log "skipping this Consul release since k8s cluster version is < 1.22"
	RELEASE=""
else

	print_log "installing Consul for k8s v.1.22+"

	# create consul CA if necessary
	consul_create_ca

	kubectl delete job consul-server-acl-init-cleanup >/dev/null 2>&1 || true

fi

# redefine chart version here
# supporting k8s v.1.22+
CHART_VER=0.47.0
