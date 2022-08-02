![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 


### Notes
1. Our examples use override value `log.volumeType: none` 

To write logging to storage, please consult with our [documentation](https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide).


2. `redis_host` and `redis_port` are optional. 

As Pulse supports only unclustered versions of redis, the example pipeline install includes an unclustered version for itself. If an unclustered redis has already been deployed, `redis_host` and `redis_port` can be defined. 

It will be used when defined code in `./pulse/01_chart_init/01_release_pulse-init/pre-release-script.sh` has been deleted or commented.  


Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`
- `secrets/deployment_secrets`

## Secrets 

`secrets/deployment_secrets`


|Key|Value|
|-|-|
gws_ClientId|pulse_client
gws_Client_Secret|secret
POSTGRES_ADDRESS|infra-postgres-postgresql.infra
POSTGRES_PASSWORD|somepass
POSTGRES_PORT|5432
POSTGRES_USER|postgres
redis_host|pulse-redis-master.pulse
redis_key|secret
redis_port|6379
tenant_id|9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
tenant_sid|100

Example `.yaml`
```
apiVersion: v1
stringData:
  gws_ClientId: pulse_client
  gws_Client_Secret: secret
  POSTGRES_ADDRESS|infra-postgres-postgresql.infra
  POSTGRES_PASSWORD|somepass
  POSTGRES_PORT|5432
  POSTGRES_USER|postgres
  redis_host: pulse-redis-master.pulse
  redis_key: secret
  redis_port: "6379"
  tenant_namespace: voice
  tenant_id: "9350e2fc-a1dd-4c65-8d40-1f75a2e080dd"
  tenant_sid: "100"
kind: Secret
metadata:
  name: deployment-secrets
  namespace: pulse
type: Opaque
```
 

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
