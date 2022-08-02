![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](all.docs.genesys.com/PEC-IWD/Current/IWDDMPEGuide) for the full configuration and deployment details.

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
The `iwddm_nexus_api_key` is taken from the nexus db:
```
 SELECT id,name FROM nex_apikeys;
```

## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
POSTGRES_ADDR| pgdb-dgt-postgresql.infra
POSTGRES_USER| postgres
POSTGRES_PASSWORD| password
gcxi_db_password| gcxi_iwddm
gcxi_db_user| gcxi_iwddm
gim_db_password| gim
gim_db_user| gim
iwddm_db_password| iwddm
iwddm_db_user| iwddm
iwddm_nexus_api_key| **from nex_apikeys** iWD Cluster API Key
tenant_sid| "100"

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: iwddm
stringData:
  POSTGRES_ADDR: pgdb-dgt-postgresql.infra
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: password
  gcxi_db_password: gcxi_iwddm
  gcxi_db_user: gcxi_iwddm
  gim_db_password: gim
  gim_db_user: gim
  iwddm_db_password: iwddm
  iwddm_db_user: iwddm
  iwddm_nexus_api_key: **from nex_apikeys** iWD Cluster API Key
  tenant_sid: "100"
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).