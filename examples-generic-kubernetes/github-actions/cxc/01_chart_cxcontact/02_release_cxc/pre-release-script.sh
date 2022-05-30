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

###############################################################################
# 			Tenant id (UUID), sid and localtion 
###############################################################################
export tenant_sid=$( get_secret tenant_sid )
export tenant_id=$( get_secret tenant_id )
export tenant_primary_location=$( get_secret tenant_primary_location )
###############################################################################
# 			Basic Authentication for GWS Services 
###############################################################################
export cxc_prov_gwsauthuser=$( get_secret cxc_prov_gwsauthuser )
export cxc_prov_gwsauthpass=$( get_secret cxc_prov_gwsauthpass )
###############################################################################
# 			Username and Password that will be used for creation of environment. 
###############################################################################
export cxc_prov_tenant_user=$( get_secret cxc_prov_tenant_user )
export cxc_prov_tenant_pass=$( get_secret cxc_prov_tenant_pass )
###############################################################################


# For validation process need to evaluate release override values here
replace_overrides cxc_redis_password              $cxc_redis_password
replace_overrides cxc_gws_client_id               $cxc_gws_client_id
replace_overrides cxc_gws_client_secret           $cxc_gws_client_secret
replace_overrides cxc_configserver_user_name      $cxc_configserver_user_name
replace_overrides cxc_configserver_user_password  $cxc_configserver_user_password
replace_overrides !tenant_sid!                    $tenant_sid
replace_overrides !tenant_id!                     $tenant_id
replace_overrides tenant_primary_location         $tenant_primary_location
replace_overrides cxc_prov_gwsauthuser            $cxc_prov_gwsauthuser
replace_overrides cxc_prov_gwsauthpass            $cxc_prov_gwsauthpass
replace_overrides cxc_prov_tenant_user            $cxc_prov_tenant_user
replace_overrides cxc_prov_tenant_pass            $cxc_prov_tenant_pass

