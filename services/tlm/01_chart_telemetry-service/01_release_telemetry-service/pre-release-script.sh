###############################################################################
# Telemetry Auth client ID, Telemetry Auth Client secret
# Typically obtained from your Deployment Secrets (DS)
###############################################################################

if [ ! "$tlm_gws_client_id" ]; then
        export tlm_gws_client_id="$TELEMETRY_AUTH_CLIENT_ID"   #alternative variable
        [[ ! "$tlm_gws_client_id" ]] && error_exit "TLM auth credentials are required"
fi
if [ ! "$tlm_gws_client_secret" ]; then
        export tlm_gws_client_secret="$TELEMETRY_AUTH_CLIENT_SECRET"   #alternative variable
        [[ ! "$tlm_gws_client_secret" ]] && error_exit "TLM auth credentials are required"
fi
