![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](all.docs.genesys.com/PEC-IWD/Current/IWDPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

### Notes
The `iwd_nexus_api_key` and `iwd_tenant_api_key` are taken from the nexus db:
```
 SELECT id,name FROM nex_apikeys;
```
The `iwd_tenant_api_key_iwddm` and `iwd_tenant_api_key_tenant` can be manually generated in any online UUID generator or in shell:
```
echo  "$(uuidgen)" | tr '[:upper:]' '[:lower:]')
```
## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
tenant_sid| 100
tenant_id| 9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
POSTGRES_ADDR| pgdb-dgt-postgresql.infra
POSTGRES_USER| postgres
POSTGRES_PASSWORD| password
iwd_db_user| iwd-100
iwd_db_password| iwd-100
iwd_gws_api_key| None
iwd_gws_client_id| external_api_client
iwd_gws_client_secret| secret
iwd_nexus_api_key| **from nex_apikeys** iWD Cluster API Key
iwd_redis_password| redPass
iwd_tenant_api_key| **from nex_apikeys** t100
iwd_tenant_api_key_iwddm| **example generated** 20993434-e6fb-4081-9b1f-5c5a7e523077
iwd_tenant_api_key_tenant| **example generated** e0c519c2-a9d5-48cc-8da9-8566fcce6575

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: iwd
stringData:
  tenant_sid: 100
  tenant_id: 9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
  POSTGRES_ADDR: pgdb-dgt-postgresql.infra
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: password
  iwd_db_user: iwd-100
  iwd_db_password: iwd-100
  iwd_gws_api_key: None
  iwd_gws_client_id: external_api_client
  iwd_gws_client_secret: secret
  iwd_nexus_api_key: **iWD Cluster API Key**
  iwd_redis_password: redPass
  iwd_tenant_api_key: t100
  iwd_tenant_api_key_iwddm: 20993434-e6fb-4081-9b1f-5c5a7e523077
  iwd_tenant_api_key_tenant: e0c519c2-a9d5-48cc-8da9-8566fcce6575
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).