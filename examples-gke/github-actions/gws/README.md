# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/GWS/Current/GWSPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

|Option|Value|
|-|-|

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`
- `secrets/deployment_secrets`

## Secrets 

`secrets/deployment_secrets`


|Key|Value|
|-|-|
gws_redis_password|redpass
gws_consul_token|1234567890
POSTGRES_USER|pgAdmin
POSTGRES_PASSWORD|pgPass
gws_pg_user|pgUser
gws_pg_pass|pgPass
gws_as_pg_user|asUser
gws_as_pg_pass|asPass
gws_app_provisioning|sample
gws_app_workspace|sample
gws_client_id|sample_id
gws_client_secret|sample_secret
gws_ops_user|opsUser
gws_ops_pass_encr|opsPass
POSTGRES_ADDR|pgHostAddress
DB_NAME_GWS|gws_db
DB_NAME_PROV|prov_db

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).