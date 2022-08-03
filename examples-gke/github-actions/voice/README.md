![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
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


|Key|Sample Value|Description
|-|-|-
CONSUL_VOICE_TOKEN|abc123|Consul ACL token
DNS_SERVER|10.12.14.16 |IP address of DNS server
KAFKA_ADDRESS|kafka-helm-cp-kafka.kafka:9092| Kafka FQDN and port
REDIS_IP|10.12.14.18 | IP address of Redis service
REDIS_PASSWORD| redpass| Redis password
REDIS_PORT| 6379| Redis port
tenant_gauth_client_id| external_api_client| Client ID for communicating with GAUTH service
tenant_gauth_client_secret| secret | Client ID secret 
POSTGRES_USER| postgres| Postgres admin account 
POSTGRES_PASSWORD| secret| Postgres admin password 
POSTGRES_ADDR| pgdb-std-postgresql.infra | Postgres address for voice
tenant_t100_pg_db_name| t100 | Tenant DB name - part of tenant deployment
tenant_t100_pg_db_password| t100| Tenant DB password - part of tenant deployment
tenant_t100_pg_db_user| t100|Tenant DB user - part of tenant deployment                     

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: voice
stringData:
  CONSUL_VOICE_TOKEN: abc123
  DNS_SERVER: 10.12.14.16
  KAFKA_ADDRESS: kafka-helm-cp-kafka.kafka:9092
  REDIS_IP: 10.12.14.18
  REDIS_PASSWORD:  redpass
  REDIS_PORT:  6379
  tenant_gauth_client_id:  external_api_client
  tenant_gauth_client_secret:  secret
  POSTGRES_USER:  postgres
  POSTGRES_PASSWORD:  secret
  POSTGRES_ADDR:  pgdb-std-postgresql.infra
  tenant_t100_pg_db_name:  t100
  tenant_t100_pg_db_password:  t100
  tenant_t100_pg_db_user:  t100
```                   

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
