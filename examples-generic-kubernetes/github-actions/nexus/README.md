# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

Update the `image.registry` setting to reflect your image repository path:
```
image:
  registry: "repository.path"
```

### Notes


Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`
- `secrets/deployment_secrets`

## Secrets 

`secrets/deployment_secrets`


|Key|Value|
|-|-|
nexus_db_password| nexusPASS
nexus_db_user| nexusUSER
nexus_gws_client_id| nexus_client
nexus_gws_client_secret| secret
nexus_redis_password| redPASS
pg_admin_pass| pgAdminPASS
pg_admin_user| pgAdmin
tenant_id| 9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
tenant_locations| westus1
tenant_primary_location| USW1
tenant_sid| 100

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).