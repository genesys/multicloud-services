###############################################################################
# Redefine helm_repo
###############################################################################
helm repo add --force-update helm_repo https://helm.releases.hashicorp.com
helm_repo_update


###############################################################################
# Create consul CA and add in secrets, if not exist
# Download consul utility and generate cert
###############################################################################
function consul_create_ca {

	if [ ! "$(kubectl get secrets consul-ca-cert)" ] || \
		[ ! "$(kubectl get secrets consul-ca-key)" ]
	then 
		print_log "CA has to be created for Consul"
		case $(uname -m) in 
			x86_64)
				zip_file=consul_1.11.2_linux_amd64.zip
				;;
			*)
				zip_file=consul_1.11.2_linux_386.zip
				;;
			
		esac
        [[ "$OSTYPE" == "darwin"* ]] && zip_file=consul_1.11.2_darwin_amd64.zip

		curl -O "https://releases.hashicorp.com/consul/1.11.2/$zip_file"
        unzip $zip_file
		chmod a+x consul
		./consul tls ca create
		ls -lsh
		kubectl create secret generic consul-ca-cert --from-file='tls.crt=./consul-agent-ca.pem'
		kubectl create secret generic consul-ca-key --from-file='tls.key=./consul-agent-ca-key.pem'
		print_log "CA has been successfully created for Consul"
	fi
}

###############################################################################
# Configure your DNS server: https://www.consul.io/docs/k8s/dns
###############################################################################
function consul_update_dns {
	
	print_log "updating cluster DNS to forward consul zone"

	# IP of consul-dns service
	CONSUL_DNS_IP_NEW=$(kubectl get svc consul-dns -n $NS -o jsonpath={.spec.clusterIP})

	# For openshift dns operator
	if [ "$CLUSTER_TYPE" == "openshift" ]
	then
		print_log "openshift-specific update"
		CURR_IP=$(kubectl get dns.operator/default -o json | jq -r .spec.servers[0].forwardPlugin.upstreams[0])
		if [ "$CURR_IP" != "$CONSUL_DNS_IP_NEW" ]; then
			print_log "Current Consul zone IP is: $CURR_IP. Updating it.."
			kubectl patch dns.operator default --type='json' \
			-p "[{ \"op\": \"replace\", \"path\": \"/spec/servers/0/forwardPlugin/upstreams/0\", \"value\": \"$CONSUL_DNS_IP_NEW\" }]"
			print_log "Successfully updated cluster DNS:"
			kubectl get dns.operator/default -o json | jq -r .spec
		fi
	
	# For coredns (eg, AKS)
	elif kubectl get cm coredns -n kube-system >/dev/null
	then
		print_log "coredns-specific update"
		# existing coredns config
		kubectl get cm coredns -n kube-system -o yaml > coredns.yaml
		cat coredns.yaml | yq .data.Corefile > cfg0
		
		# if no consul zone forwarding defined yet
		if ! grep 'consul:53' cfg0 >/dev/null; then
			cat <<EOF >> cfg0
consul:53 {
  errors
  cache 30
  forward . $CONSUL_DNS_IP_NEW
}
EOF
			yq eval '.data.Corefile = "'"$(< cfg0)"'"' coredns.yaml \
				| kubectl apply -f -
			print_log "consul zone forwarding has been added to coredns config"
		
		elif ! grep "forward . $CONSUL_DNS_IP_NEW" cfg0 >/dev/null; then
			# update existing forwarding, if current IP is dofferent
			ip0=$(grep 'consul:53' -A3 cfg0| grep forward| awk '{print $3}')
			kubectl get cm coredns -n kube-system -o yaml | \
				sed "s/$ip0/$CONSUL_DNS_IP_NEW/" | kubectl apply -f -
			print_log "consul zone forwarding IP has been updated in coredns config"

		else
			print_log "coredns config does not require updating"
		fi

## Optionally can use coredns-custom configmap
# 		cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: coredns-custom
#   namespace: kube-system 
# data:
#   consul.server: |
#     consul:53 {
#       errors
#       cache 30
#       forward . $CONSUL_DNS_IP_NEW
#     }
# EOF

	# For kube-dns (eg, GKE, mk8s)
	else
		print_log "kubedns-specific update"
		CURR_IP=$(kubectl get cm kube-dns -n kube-system -o json | jq -r .data.stubDomains | jq -r .consul[0])
		if [ "$CURR_IP" != "$CONSUL_DNS_IP_NEW" ]; then
			echo "Current Consul zone IP is: $CURR_IP. Updating it.."
			kubectl patch cm kube-dns -n kube-system --type='json' \
			-p '[{ "op":"replace", "path":"/data/stubDomains", "value":"{\"consul\": [\"'$CONSUL_DNS_IP_NEW'\"] }" }]'
			echo "Successfully updated cluster DNS:"
			kubectl get cm kube-dns -n kube-system -o json | jq -r .data
		fi
	fi

	# ..
}