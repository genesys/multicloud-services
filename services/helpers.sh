#############################################################################
# Helper functions
#############################################################################


function print_log {
    ####################################################
    # Using: print_log "your log message" [ <log_type> ]
    ####################################################

    [ "$2" ] && lt="$2 - " || lt=""
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${lt}${1}"
}

function error_exit {
    ##################################################
    # Using: error_exit [ error_message ]
    ##################################################

    print_log "❌ exit with error: ${1:-"Unknown Error"}" ERROR 1>&2
    exit 1
}

###############################################################################
function get_k8s_version {
    local kv=$(kubectl version --short 2>/dev/null| grep 'Server Version'| \
        awk '{print $3}'| cut -c2-| cut -d'.' -f1-2) #sed 's/v\([0-9]\+\.[0-9]\+\).*/\1/')
    [[ ! "$kv" ]] && error_exit "could not detect k8s cluster version" || echo $kv
}

function get_helm_version {
    local hv=$(helm version --short 2>/dev/null| cut -c2-| cut -d'.' -f1-2)  #sed 's/v\([0-9]*\.[0-9]*\).*/\1/')
    [[ ! "$hv" ]] && error_exit "could not detect installed Helm version" || echo $hv
}

###############################################################################
function helm_repo_update {
    ##################################################
    # Usage: helm_repo_update [repo_name]
    # By default tries to update helm repo "repo_name"
    # Improves speed for Helm v.3.7+
    ##################################################
    local hrn=${1:-helm_repo}
    if [[ $(get_helm_version | awk '{if ($1 >= 3.7) print 1}') == "1" ]]; then
        print_log "newer Helm version, updating particular helm repo - $hrn"
        helm repo update $hrn
    else
        print_log "older Helm version, updating all helm repos.."
        helm repo update
    fi
}

###############################################################################
function wait_running_status {
    ##################################################
    # Using: wait_running_status pod-labels [time_limit]
    ##################################################
    labels=$1; pod_status="Running"; time_limit=${2:-60}
    n=$(expr $time_limit / 5)
    print_log "Check that all pods with labels <$labels> have status <$pod_status>"
    for i in $(seq 1 $n); do
      print_log "${i}) waiting for pods to get status $pod_status ..." && sleep 5
      kubectl get pods -l $labels --no-headers 
      PSTAT=$(kubectl get pods -l $labels --no-headers | awk '{print $3}' | sort | uniq)
      if [[ "$PSTAT" == "$pod_status" ]]; then
          print_log "Checking all of containers is running..."
          s=$(kubectl get pods -l $labels --no-headers | awk '{print $2}' | sort | uniq)
          print_log "Containers STATUS: $s"
          c_run=$(echo $s | sed 's/\/.*//')
          c_plan=$(echo $s | sed 's/.*\///')
          [[ "$c_run" == "$c_plan" ]] && break
      fi
      [[ $i == $n ]] && error_exit "can't get pods in status: $pod_status"
    done
    print_log "All pods with labels <$labels> are in <$pod_status> status!"
}


###############################################################################
# Helm override values are same for all clusters,
# except a few parameters that we keep in k8s secrets we name "Deployment Secrets".
# This is recommended method to keep your credentials, tokens, etc. as Kubernetes
# natively provides you with ability to secure your secrets via RBAC.
# Algorithm of reading the Deployment Secrets (DS):
# - read "global-deployment-secrets" in namespace "default" - stores global parameters.
# - read "<service>-deployment-secrets" in local/service namespace, if present.
#   OR read "deployment-secrets" in local/service namespace, if present.
#   <service>-deployment-secrets comes handy when you deploy multiple services in same 
#   namespace.

# DS are all optional, but your per-service code and overrides may require DS.
# Per-service DS are retrieved after global ones, hence you can override
# parameters globals by locals.
# Extracted secrets are converted to Env variables and then used in scrpipts and helm overrides.

######## Example of DS ###############
#  apiVersion: v1
#  kind: Secret
#  type: Opaque
#  metadata:
#      name: global-deployment-secrets
#      namespace: default
#  stringData:
#      LOCATION: USW1
#      DOMAIN: mycluster.example.com

# Create or update secret from text file:
# $ kubectl apply -f <file_name>
# Read secret in command line (you may use GUI tools as well):
# $ kubectl get secret <secret_name> -o json | jq '.data | map_values(@base64d)'

###############################################################################

function fetch_deployment_secrets {
  # Usage: fetch_deployment_secrets [namespace] [secret_name]
  # Tries to fetch ENV variables from k8s secrets.
  #  - namespace   - self explanatory, and default namespace is current.
  #  - secret_name - if specified, we read this secret only (if exists).
  # Otherwise we try "<service>-deployment-secrets" secret if exists (optional).
  # Otherwise we try "deployment-secrets" if exists (optional).

  ns=$NS; [[ "$1" ]] && ns=$1
  print_log "Looking for deployment-secrets in namespace $ns"

  if [ "$2" ]; then
      print_log "Secret $2 has been requested"
      if kubectl get secret $2 -n $ns >/dev/null 2>&1 ; then
          kubectl get secret $2 -n $ns -o json| jq .data > ds
          print_log "Using $2"
      else
          print_log "Secret $2 is NOT found in namespace $ns"
      fi
  
  elif kubectl get secret $SERVICE-deployment-secrets -n $ns >/dev/null 2>&1 ; then
      kubectl get secret $SERVICE-deployment-secrets -n $ns -o json| jq .data > ds
      print_log "Using $SERVICE-deployment-secrets"
  
  elif kubectl get secret deployment-secrets -n $ns >/dev/null 2>&1 ; then
      kubectl get secret deployment-secrets -n $ns -o json| jq .data > ds
      print_log "Using deployment-secrets"
  
  else 
      print_log "Deployment secrets are NOT found in namespace $ns"
  fi

  touch ds
  for k in $(jq '. | keys | .[]' ds); do
      key=$(echo $k| sed 's/\"//g')
      value=$(jq -r .["$k"] ds | base64 -d)
      export $key="$value"
  done
}

###############################################################################
# Get secret variable
function get_secret {
    ############################################################
	# Using: get_secret  secret_name secret_variable [namespace]
    ############################################################
    ns=$NS
    [[ "$3" ]] && ns=$3
	echo $( kubectl get secret $1 -n $ns -o jsonpath={.data.$2} | base64 -d )
}

# Get entire secret data as JSON
function get_secret_json {
    ###########################################################
	# Using: get_secret secret_name [namespace]
    ###########################################################
    ns=$NS
    [[ "$2" ]] && ns=$2
	echo $( kubectl get secret $1 -n $ns -o json | jq '.data | map_values(@base64d)' )
}

#######################################################################################
# List helm override files in current directory.
# If present, these files will be used in helm command line:
#   - override_values.yaml
#   - override_values_<CLUSTER_TYPE>.yaml
#   - override_values_<CLUSTER>.yaml
# ❗ Helm is combining (merging) overrides from multiple YAML files, and last specified
#    override file takes precedence if there is overlap in properties.
#    Then helm merges resulting overrides with default values in installed chart.
#    After deployment you can look at rendered and merged values within installed
#    helm release, using command `helm get values <release_name>`
function list_override_files {
    ############################
	# Using: list_override_files
    ############################

    res=""

    # first try to read from override_values.yaml
    # this file contains most general parameters
    if [[ -s "override_values.yaml" ]]; then
        envsubst < override_values.yaml > override_values.yaml_
        res+=" -f $(pwd)/override_values.yaml_"
    fi

    # then try to read from override_values_<CLUSTER_TYPE>.yaml
    # this file contains cluster-type specific parameters
    if [[ -s "override_values_${CLUSTER_TYPE}.yaml" ]]; then
        envsubst < override_values_${CLUSTER_TYPE}.yaml > override_values_${CLUSTER_TYPE}.yaml_
        res+=" -f $(pwd)/override_values_${CLUSTER_TYPE}.yaml_"
    fi

    # then try to read from override_values_<CLUSTER>.yaml
    # this file contains cluster-specific parameters
    if [[ -s "override_values_${CLUSTER}.yaml" ]]; then
        envsubst < override_values_${CLUSTER}.yaml > override_values_${CLUSTER}.yaml_
        res+=" -f $(pwd)/override_values_${CLUSTER}.yaml_"
    fi

    echo "$res"
}

###############################################################################
# Create Postgre DB
#
function create_pg_db {
	# Usage:
	# create_pg_db db_name - creating database with name: <db_name>
	# create_pg_db db_name db_user db_password - creating database with name: <db_name> and 
	#   user with credentials: <db_user>/<db_password> and full access to db: <db_name>
    # create_pg_db db_name db_user db_password pg_host
    # create_pg_db db_name db_user db_password pg_host pg_admin_user pg_admin_password

  print_log "Create DB function called"
  if [ "$#" -eq 1 ] || [ "$#" -ge 3 ]; then
    db_name=$1
    db_user=$2
    db_password=$3
    [[ "$4" ]] && pg_host=$4             || pg_host=$POSTGRES_ADDR
    [[ "$5" ]] && pg_admin_user=$5       || pg_admin_user=$POSTGRES_USER
    [[ "$6" ]] && pg_admin_password="$6" || pg_admin_password="$POSTGRES_PASSWORD"
    
    kubectl delete pod db-init > /dev/null 2>&1 || true
    kubectl run db-init --image=postgres --env=PGUSER=${pg_admin_user} \
      --env=PGPASSWORD="${pg_admin_password}" --labels="servicename=db-provisioning" \
      --restart='Never' --command -- sh -c \
      "psql -h $pg_host -tc \"SELECT 1 FROM pg_database WHERE datname = '$db_name'\"| grep -q 1 || \
        psql -h $pg_host -c \"CREATE DATABASE \\\"$db_name\\\"\"
      if [ $db_user ] && [ $db_password ] && \
        ( ! psql -h $pg_host -tc \"SELECT 1 FROM pg_user WHERE usename = '$db_user'\" | grep -q 1 )
      then
        psql -h $pg_host -c \"CREATE USER \\\"$db_user\\\" WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION CONNECTION LIMIT -1 PASSWORD '$db_password'\"
        psql -h $pg_host -c \"GRANT all privileges on database \\\"$db_name\\\" to \\\"$db_user\\\"\"

      fi
      "
  else
    error_exit "wrong usage of function <create_pg_db>"
  fi
  return 0
}

###############################################################################
# Creates basic Consul Intention all-to-all via Consul CLI
# (requires CONSUL_BOOT_TOKEN in deployment secrets)
# Allows connections via Consul service mesh
# Use it after Consul deployment and before Voice deployment
# 
function create_consul_intention {
    ################################################
    # Usage: create_consul_intention
    ################################################
    print_log "Create Consul intention all-to-all if not present"
    po=$(kubectl get po --no-headers -A| grep -m1 consul-server-0| awk '{print $2}')
    [[ ! "$po" ]] && error_exit "Could not locate Consul server pods"
    kubectl exec $po -- sh -c "consul intention create -token $CONSUL_BOOT_TOKEN -allow '*' '*'" || true
}

###############################################################################
# Run init script is present
function run_init {
    if [ -f 00_init/script.sh ]; then
        cd 00_init
            print_log "Run init script"
            source script.sh
        cd ..
    fi
    return 0
}

###############################################################################
# If DEBUG_HELM or DEBUG_<service> variable is set to "true" (via DS)
# Render helm template and save manifest to file
# "artifacts" folder content then will be archived and saved in GHA run
#
function try_helm_debug {

    varname=DEBUG_${SERVICE^^}
    if [ "$DEBUG_HELM" == "true" ] || [ "${!varname}" == "true" ]; then
        print_log "render Helm template and save in artifacts" DEBUG
        
        PARAMS+=" --debug"
        PARAMS_RLT=$(echo "$PARAMS"| sed 's/--install//')    #helm template can't handle --install flag
        mkdir -p ../../artifacts
        print_log "$RELEASE $PARAMS_RLT" DEBUG
        helm template $RELEASE --version=$CHART_VER $PARAMS_RLT > ../../artifacts/${DIR_CH}.${DIR_RL}.yaml
    fi
}

###############################################################################
# Check if installed Helm release is tenant-specific
# meaning that <TENANT_SID> should be added to its name
#
function tenant_specific_release {
    ####################################################
    # Usage: tenant_specific_release <helm_release_name>
    ####################################################

    #***********
    service_list="tenant gca gcxi gcxi-raa ucsx-addtenant ixn iwddm \
                  pulse-dcu pulse-lds pulse-lds-vq pulse-permissions pulse-init-tenant"
    #***********

    for i in $service_list
    do 
        [[ "$i" == "$1" ]] && return 0
    done
    
    return 1
}

###############################################################################
# GAuth API
# To add or update origin/subdomain per GAuth "contact-center" $TENANT_UUID
function gauth_update_cors {
      ###################################
      # Usage: gauth_cors.sh [ location ]
      ###################################

    LOC=${1:-"/$LOCATION"}

    # These should be already known from global depl secrets:
    # - gauth_admin_username
    # - gauth_admin_password_plain

    [[ ! "$gauth_admin_username" ]] || [[ ! "$gauth_admin_password_plain" ]] \
        && error_exit "please provide GAuth admin creds in your global depl secrets"
    CREDS="$gauth_admin_username:$gauth_admin_password_plain"

    # We will Curl from gauth pod, because there may be no access from GH runner to ingress https://gauth.$DOMAIN
    GAPOD=$(kubectl get po -n ${GAUTH_NAMESPACE} | grep gauth-auth | grep Running | grep -v gauth-auth-ui -m1 | awk '{print $1}')

    print_log "*** Pre-change list of origins:"
    kubectl exec $GAPOD -n ${GAUTH_NAMESPACE} -- \
        bash -c "curl -s http://gauth-environment/environment/v3/contact-centers/${TENANT_UUID}/settings \
        -u $CREDS" | jq .data.settings

    # Older API - add all origins in one request (update list if needed)
    CORS="https://gauth.$DOMAIN, \
https://gws.$DOMAIN, \
https://wwe.$DOMAIN, \
https://prov.$DOMAIN, \
https://webrtc.$DOMAIN, \
https://cxc.$DOMAIN, \
https://designer.$DOMAIN, \
https://iwd.$DOMAIN, \
https://digital.$DOMAIN, \
https://pulse.$DOMAIN, \
https://web-gcxi.$DOMAIN, \
https://web-gcxi-100.$DOMAIN, \
https://ges.$DOMAIN"

    ORIGINS()
    {
    cat <<EOF
{ "data": {
        "location": "$LOC",
        "name": "cors-origins",
        "shared": "true",
        "value": "$CORS"
        }
}
EOF
    }

    kubectl exec $GAPOD -n ${GAUTH_NAMESPACE} -- \
        bash -c "curl -s -XPOST http://gauth-environment/environment/v3/contact-centers/${TENANT_UUID}/settings \
        -u $CREDS -H 'Content-Type: application/json' -d '$(ORIGINS)'" | tee RSP

    #######
    sleep 5
    [[ "$(cat RSP | jq .status.code)" != "0" ]] && error_exit "failed http request to Gauth"

    print_log "*** Latest list of origins:"
    kubectl exec $GAPOD -n ${GAUTH_NAMESPACE} -- \
        bash -c "curl -s http://gauth-environment/environment/v3/contact-centers/${TENANT_UUID}/settings \
        -u $CREDS" | jq .data.settings

}