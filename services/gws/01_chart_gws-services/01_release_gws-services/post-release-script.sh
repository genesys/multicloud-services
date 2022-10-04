# Set these variables via your deployment secrets
# - gws_set_clients=true  - creates a bunch of auth clients & secrets, for most Genesys services
# - gws_set_cors=true     - adds list of CORS origins for GAuth environment

if [ "$gws_set_clients" == "true" ]; then
    echo ##############################
    echo "Adding GAUTH API Clients"
    source ./gauth_apiclient.sh add all
fi

# Adding CORS per tenant (moved to Tenant post-release)
# This will fail if tenant is not installed yet
# if [ "$gws_set_cors" == "true" ]; then
#     echo ##############################
#     echo "Adding CORS settings"
#     gauth_update_cors
# fi