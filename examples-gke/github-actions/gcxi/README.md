# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/PEC-REP/Current/GCXIPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

Update the `image.registry` setting to reflect your image repository path:
```
image:
  registry: "repository.path"
```

### Notes
:memo: Optionally, **gcxi** deployment can be populated with `deployment secrets` of **gim**, and **iwd** in their corresponding namespaces to automatically connect to their databases. See the `pre-release-script.sh` for more details.

## Secrets 
Create the standard [pullsecret](../github-actions#-considerations) for the workflow: 
`secrets/pullsecret`
`secrets/deployment_secrets`


|Key|Value|
|-|-|
tenant_sid| 100
tenant_id| 9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
gim_db_host| gim.db.host
gim_db_name| gim
gim_db_user| gimuser
gim_db_pass| gimpass
iwd_db_host| iwd.db.host
iwd_db_name| iwd-100
iwd_db_user| iwduser
iwd_db_pass| iwdpass
gcxi_db_host| gcxi.db.host
gcxi_db_name| postgres
pg_admin_user| postgres
pg_admin_pass| somepass
GAUTH_CLIENT| gcxi_client
GAUTH_KEY| secret
repo_path| repository.path



Example `.yaml`
```
apiVersion: v1
stringData:
  tenant_sid: 100
  tenant_id: 9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
  gim_db_host: gim.db.host
  gim_db_name: gim
  gim_db_user: gimuser
  gim_db_pass: gimpass
  iwd_db_host: iwd.db.host
  iwd_db_name: iwd-100
  iwd_db_user: iwduser
  iwd_db_pass: iwdpass
  gcxi_db_host: gcxi.db.host
  gcxi_db_name: postgres
  pg_admin_user: postgres
  pg_admin_pass: somepass
  GAUTH_CLIENT: gcxi_client
  GAUTH_KEY: secret
  repo_path: repository.path
kind: Secret
metadata:
  name: deployment-secrets
  namespace: gcxi
type: Opaque
```
 

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
