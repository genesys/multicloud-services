![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](all.docs.genesys.com/PEC-CAB/Current/CABPEGuide) for the full configuration and deployment details.

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
GES works only with unclustered Redis. We've included `01_chart_redis` to include this in the installation process.

## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
POSTGRES_ADDR| pgdb-std-postgresql.infra
POSTGRES_USER| postgres
POSTGRES_PASSWORD| password
AUTHENTICATION_CLIENT_ID| ges_client
AUTHENTICATION_CLIENT_SECRET| secret
DB_NAME| ges
DB_PASSWORD| ges
DB_USER| ges
DEVOPS_PASSWORD| letmein
DEVOPS_USERNAME| admin
REDIS_ORS_PASSWORD| redOrsPass
REDIS_PASSWORD| redPass

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: ges
stringData:
  POSTGRES_ADDR: pgdb-std-postgresql.infra
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: password
  AUTHENTICATION_CLIENT_ID: ges_client
  AUTHENTICATION_CLIENT_SECRET: secret
  DB_NAME: ges
  DB_PASSWORD: ges
  DB_USER: ges
  DEVOPS_PASSWORD: letmein
  DEVOPS_USERNAME: admin
  REDIS_ORS_PASSWORD: redOrsPass
  REDIS_PASSWORD: redPass
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).