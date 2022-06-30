###############################################################################
# Because of using helm-repo as private repository  in gh-workflow,
# we have to reddefine it for installing from public ones 
###############################################################################
helm repo add --force-update helm_repo https://helm.releases.hashicorp.com
helm repo update


###############################################################################
# Download consul utility and generate certs
###############################################################################
if [ ! "$(kubectl get -n $NS secrets consul-ca-cert)" ] || \
	[ ! "$(kubectl get -n $NS secrets consul-ca-key)" ]
then 
	case $(uname -m) in 
		x86_64)
			zip_file=consul_1.11.2_linux_amd64.zip
			;;
		*)
			zip_file=consul_1.11.2_linux_386.zip
			;;
			

	esac
	curl "https://releases.hashicorp.com/consul/1.11.2/$zip_file" --output - | zcat > consul
	chmod a+x consul
	./consul tls ca create
	ls -lsh
	kubectl create secret generic consul-ca-cert --from-file='tls.crt=./consul-agent-ca.pem'
	kubectl create secret generic consul-ca-key --from-file='tls.key=./consul-agent-ca-key.pem'
fi


###############################################################################
# Configure your DNS server: https://www.consul.io/docs/k8s/dns
###############################################################################