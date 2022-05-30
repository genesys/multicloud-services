###############################################################################
# All secrets sould be saved in secrets: deployment-secrets
# 								Using it! 
# We extract secrets to environment variables. It will evaluate variables in
# override values by workflow.
###############################################################################
function get_secret {
	# Using: get_secret secret_name
	echo $( kubectl get secrets deployment-secrets -o custom-columns=:data.$1 \
			--no-headers | base64 -d )
}

function replace_overrides {
  # Using: replace_overrides old_value new_value
  ESCAPED_S=$(printf '%s' "$2" | sed -e 's/[\/&]/\\&/g')
  cat override_values.yaml | sed "s/$1/$ESCAPED_S/g" > override_values.tmp \
     && mv override_values.tmp override_values.yaml 
}

function find_in_overrides {
	# Using: find_in_overrides yaml_path [lookup_arg1, lookup_arg2]
	#
	# try to parse by yq (if installed) then by awk (if false set to default)
	
	res=$(cat override_values.yaml | yq eval $1 - 2>/dev/null)
	if [[ ! "$res" ]] && [[ $2 ]] && [[ $3 ]]; then
		res=$(cat override_values.yaml | grep "$2" | grep "$3" \
				| awk '{print $2}')
	fi
	[[ ! "$res" ]] && res="not found"
	echo $res
}

###############################################################################
# 			Redis credentials 
###############################################################################
export cxc_redis_password=$( get_secret cxc_redis_password )
###############################################################################
# 			CXC gauth credentials 
###############################################################################
export cxc_gws_client_id=$( get_secret cxc_gws_client_id )
export cxc_gws_client_secret=$( get_secret cxc_gws_client_secret )
###############################################################################
# 			Configserver credentials
###############################################################################
export cxc_configserver_user_name=$( get_secret cxc_configserver_user_name )
export cxc_configserver_user_password=$( get_secret cxc_configserver_user_password )
###############################################################################


# For validation process need to evaluate release override values here
replace_overrides cxc_redis_password 							$cxc_redis_password
replace_overrides cxc_gws_client_id 							$cxc_gws_client_id
replace_overrides cxc_gws_client_secret 					$cxc_gws_client_secret
replace_overrides cxc_configserver_user_name 			$cxc_configserver_user_name
replace_overrides cxc_configserver_user_password 	$cxc_configserver_user_password

################################ IMPORTANT ####################################
# Like with Designer, CXC requires mount options with "uid=<arb_uid>" in 
# storage class where arb_uid is arbitrary UID assigned by Openshift to pods 
# in this namepace
# Need also enforce this UID in securityContext.runAsUser further
ARB_UID=$(oc describe project $NS | grep 'sa.scc.uid-range'| cut -d'=' -f2| cut -d'/' -f1)
pv_provisioner=$(find_in_overrides ".storage.provisioner" "provisioner:" "provisioner:")
###############################################################################
# 			Creating StorageClass
###############################################################################
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: cxc-storage
mountOptions:
- dir_mode=0777
- file_mode=0777
- uid=$ARB_UID
- gid=0
- mfsymlinks
- cache=strict
#- actimeo=30
provisioner: $pv_provisioner
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
EOF