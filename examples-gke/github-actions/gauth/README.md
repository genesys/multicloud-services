# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

*Note!* The example includes a Java KeyStore to use [JSON Web Token authentication](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Configure). Replace the `<key content>` variable found within the `override_values.yaml`.

```
  auth:
    jks:
      keyStoreFileData: <key content>	
```
## Secrets 

Create the following secrets within the namespace of the service.

`secrets/pullsecret`  -  [standard pullsecret](../#-considerations) for the workflow 

`secrets/deployment_secrets`  -  Include the following key/value data.

|Key|Sample Value|
|-|-|
POSTGRES_ADDR|pgdb-gws-postgresql.infra.svc.cluster.local
DB_NAME|gauth
POSTGRES_ADMIN_USER|pgADMIN
POSTGRES_ADMIN_PASS|pgPASS
gauth_admin_password|gadminPASS
gauth_admin_password_plain|
gauth_admin_username|gadminUSER
gauth_gws_client_id|gwsCLIENT
gauth_gws_client_secret|gwsSECRET
gauth_jks_keyPassword|jksPASS
gauth_jks_keyStorePassword|jksstorePASS
gauth_pg_password|gpgPASS
gauth_pg_username|gpgUSER
gauth_redis_password|redPASS

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
