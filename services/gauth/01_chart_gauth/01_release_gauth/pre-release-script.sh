###############################################################################
# Posgress database
###############################################################################
[[ ! "$gauth_pg_dbname" ]] && export gauth_pg_dbname="gauth"
[[ "$POSTGRES_GWS_ADDR" ]] && export POSTGRES_ADDR="$POSTGRES_GWS_ADDR"
[[ ! "$gauth_pg_username" ]] && export gauth_pg_username=gauth
[[ ! "$gauth_pg_password" ]] && export gauth_pg_password=gauth

###############################################################################
# Creating gauth DB if not exists
###############################################################################
envsubst < create_gauth_db.sh > create_gauth_db.sh_
kubectl run db-init -i --rm --image=alpine --restart=Never -- sh -c "$(<create_gauth_db.sh_)"


###############################################################################
# GAUTH JKS KEYSTORE
# if already provided via deployment secrets, keep using it
# if not provided, we:
#   - will try to get it from previously installed helm release
#   - otherwise generate it here
###############################################################################

if [ ! "$gauth_jks_key" ]
then

    # Try to retrieve JKS key value from previous successful helm release
    if helm status gauth 2>/dev/null | grep 'STATUS: deployed'
    then
        export gauth_jks_key=$(helm get values gauth -o json | jq -r '.services.auth.jks.keyStoreFileData')
    
    else
        # Otherwise, generate a new JKS key
        # Further we recommend to put this value into deployment secrets
        
        # 🖊️ EDIT -dname values as needed eg. CN=<value>, OU=<value>, O=<value>, L=<value>, S=<value>, C=<value>

        # Note: keytool comes with JDK and may not be available in your runner
        #       If so, generate JKS key manually and provide it via depl secrets in gauth_jks_key variable
        keytool -keystore keystore.jks -genkey -alias gws-auth-key -keyalg RSA \
            -storepass $gauth_jks_keyStorePassword \
            -keypass $gauth_jks_keyPassword  \
            -dname "CN=$DOMAIN, OU=pe, O=genesys, L=DalyCity, S=California, C=US"

        export gauth_jks_key=$(cat ./keystore.jks | base64 | tr -d '[:space:]')

        print_log "Generated Keystore: $gauth_jks_key"
    fi

fi