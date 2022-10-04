 [![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![docs](https://badgen.net/badge/Genesys%20Documentation/GAuth/orange)](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Overview)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

*Note!* The example includes a Java KeyStore to use [JSON Web Token authentication](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Configure). Replace the `<key content>` variable found within the `override_values.yaml`.

```
  auth:
    jks:
      keyStoreFileData: <key content>	
```
## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | - | 
Ingress |:heavy_check_mark: | external https access
Cert manager | :heavy_check_mark: | optional, for ingress tls
Consul |- |
Kafka |- |
REDIS |:heavy_check_mark: |
DB Server |:heavy_check_mark:|
Elasticsearch | -|

## Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.

|:key: Key|:anchor: Default Value|:pencil2: Sample Value|:book: Description
|-|:-:|:-|-|
LOCATION| (global ds)
POSTGRES_ADDR | $POSTGRES_GWS_ADDR (global DS)| 	
POSTGRES_USER |(global DS)
POSTGRES_PASSWORD |(global DS)
REDIS_ADDR | (global DS)
REDIS_PORT | (global DS)
REDIS_PASSWORD |  (global DS)
gauth_pg_dbname | gauth
 :asterisk: gauth_pg_username|- |gauthUser|GAuth DB user
 :asterisk: gauth_pg_password|- |gauthPass|GAuth DB password
 :asterisk: gauth_jks_keyPassword |-|keyPass | key password
 :asterisk: gauth_jks_keyStorePassword |-|keyStorePass|keystore password
 :asterisk: gauth_gws_client_id |-|gauth_client|Client ID for communicating with GAuth service
 :asterisk: gauth_gws_client_secret |-|- |Client ID secret **b64 encoded b64 value**
 :asterisk: gauth_admin_password |-| -|GAuth admin password **bcrypt encoded**
 :asterisk: gauth_admin_password_plain |-|gadminPass
 :asterisk: gauth_admin_username |-| gadminUser|GAuth admin user


An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: gauth
stringData:
  gauth_pg_dbname: gauth
  gauth_pg_username: gauthUser
  gauth_pg_password: gauthPass
  gauth_redis_password: redPass
  gauth_admin_username: gadminUser
  gauth_admin_password: -
  gauth_admin_password_plain: gadminPass
  gauth_gws_client_id: gauth_client
  gauth_gws_client_secret: -
  gauth_jks_keyPassword: keyPass 
  gauth_jks_keyStorePassword: keyStorePass
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).