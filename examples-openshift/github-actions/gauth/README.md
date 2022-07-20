![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
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
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
POSTGRES_ADDR|pgdb-gws-postgresql.infra.svc.cluster.local
DB_NAME|gauth
POSTGRES_USER|postgres
POSTGRES_PASSWORD|postgresPass
gauth_pg_password|gauthPass
gauth_pg_username|gauthUser
gauth_redis_password|redPass
gauth_admin_password|gadminPass **base64 encoded**
gauth_admin_username|gadminUser
gauth_gws_client_id|gauth_client
gauth_gws_client_secret|gauth_secret **base64 encoded**
gauth_jks_keyPassword|keyPass
gauth_jks_keyStorePassword|keyStorePass
LOCATION|USW1

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: gauth
stringData:
  POSTGRES_ADDR: pgdb-gws-postgresql.infra.svc.cluster.local
  DB_NAME: gauth
  gauth_pg_username: gauthUser
  gauth_pg_password: gauthPass
  gauth_redis_password: redPass
  gauth_admin_username: gadminUser
  gauth_admin_password: base64 encoded gadminPass
  gauth_gws_client_id: gauth_client
  gauth_gws_client_secret: base64 encoded gauth_secret
  gauth_jks_keyPassword: keyPass 
  gauth_jks_keyStorePassword: keyStorePass
  LOCATION: USW1
```
## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
