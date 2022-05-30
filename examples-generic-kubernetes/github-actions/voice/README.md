# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/VM/Current/VMPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`
- `secrets/deployment_secrets`

## Secrets 

**Note** As tenant will share the same namespace as voice services, we recommend using a common deployment secret `deployment_secrets` for the two services. 


|Key|Value|
|-|-|
CONSUL_VOICE_TOKEN|abc123
DNS_SERVER|dns.address 
KAFKA_ADDRESS|kafka.address
REDIS_IP|123.123.123.123
REDIS_PASSWORD| redpass
REDIS_PORT| 6379
tenant_gauth_client_id| client_id
tenant_gauth_client_secret| client_secret
POSTGRES_USER| ADMIN
POSTGRES_PASSWORD| PASS
POSTGRES_ADDR| server.address
tenant_t100_pg_db_name| t100
tenant_t100_pg_db_password| t100pass
tenant_t100_pg_db_user| t100user                     

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
