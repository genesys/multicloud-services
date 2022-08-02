![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/UCS/Current/UCSPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

Update the `image.registry` setting to reflect your image repository path:
```
image:
  registry: repository.path
```

### Notes

1. For provisioning multitenant implementations, add additional tenant release charts. 
2. Chart 02_chart_ucsx-addtenant is the provisioning chart for the initial tenant.

<pre>
ucsx
├── 01_chart_ucsx
├── 02_chart_ucsx-addtenant
│   ├── 01_release_ucsx-addtenant-100-register
│   ├── chart.ver
│   └── override_values.yaml
├── 03_chart_ucsx-addtenant
│   ├── 01_release_ucsx-addtenant-101-register
│   ├── chart.ver
│   └── override_values.yaml
</pre>



Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`
- `secrets/deployment_secrets`

## Secrets 

`secrets/deployment_secrets`


|Key|Value|
|-|-|
POSTGRES_ADDR|pgdb-dgt-postgresql.infra.svc
DB_NAME_UCSX|ucsx
ucsx_gauth_client_id| ucsx_api_client
ucsx_gauth_client_secret| secret
POSTGRES_PASSWORD| postgresPASS
POSTGRES_USER| postgresUSER
ucsx_tenant_100_db_name| ucsx_t100
ucsx_tenant_100_db_password| ucsx
ucsx_tenant_100_db_user| ucsx_t100
ucsx_sid|100
ucsx_tenant_id|9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
ucsx_registry|repository.path
LOCATION|/


## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
