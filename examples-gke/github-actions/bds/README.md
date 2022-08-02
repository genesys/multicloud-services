![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/BDS/Current/BDSPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`


The BDS configuration secrets must be saved in a secrets file: 
`secrets/bds-manual-secrets`
                
A sample `bds-manual-secrets.yaml` file is provided for reference, and can also be found [here](/01_chart_bds-cronjob/01_release_bds-cronjob/bds-manual-secrets_example.yaml). Please consult the official [documentation](https://all.docs.genesys.com/BDS/Current/BDSPEGuide/Provision#OpenShift) for additional details. 


```
apiVersion: v1
kind: Secret
metadata:
  name: bds-manual-secrets
type: Opaque
stringData:
  BDS_CFG_BDS_GLOBALS_GWS_CLIENTID_PLACEHOLDER: your_api_client
  BDS_CFG_BDS_GLOBALS_GWS_CLIENT_SECRET_PLACEHOLDER: xxx
  BDS_CFG_BDS_GWS_CLIENTID_PLACEHOLDER: your_api_client
  BDS_CFG_BDS_GWS_CLIENT_SECRET_PLACEHOLDER: xxx
  BDS_CFG_CONSUL_TOKEN_PLACEHOLDER: your_consul_token
  BDS_CFG_CONSUL_URL_API_PLACEHOLDER: https://consul-server.infra.svc.cluster.local
  BDS_CFG_CONSUL_URL_API_REGION_PLACEHOLDER: https://consul-server.infra.svc.cluster.local
  BDS_CFG_CONSUL_WESTUS2_TOKEN_PLACEHOLDER: your_consul_token
  BDS_CFG_CONTACT_CENTER_ID_PLACEHOLDER: 9350e2fc-a1dd-4c65-8d40-1f75a2e080dd
  BDS_CFG_CS_CONSUL_PLACEHOLDER: tenant-9350e2fc-a1dd-4c65-8d40-1f75a2e080dd.voice.svc.cluster.local
  #BDS_CFG_DEV_GLOBALS_SFTP_PSW_PLACEHOLDER: pass
  #BDS_CFG_DEV_GLOBALS_SFTP_USR_PLACEHOLDER: user
  BDS_CFG_GIR_ES_PLACEHOLDER: ""
  BDS_CFG_GLOBALS_CME_GVP_PSW_PLACEHOLDER: password
  BDS_CFG_GLOBALS_CME_GVP_USER_PLACEHOLDER: default
  BDS_CFG_GLOBALS_CME_PSW_PLACEHOLDER: password
  BDS_CFG_GLOBALS_CME_USER_PLACEHOLDER: default
  BDS_CFG_GLOBALS_GIM_DB_HOST_PLACEHOLDER: postgres-postgresql.infra.svc.cluster.local
  BDS_CFG_GLOBALS_GIM_DB_NAME_PLACEHOLDER: gim
  BDS_CFG_GLOBALS_GIM_DB_PSW_PLACEHOLDER: gim
  BDS_CFG_GLOBALS_GIM_DB_USR_PLACEHOLDER: gim
  BDS_CFG_GLOBALS_GVP_DB_NAME_PLACEHOLDER: gvp_rs
  BDS_CFG_GLOBALS_GVP_DB_PL_EASTUS2_HOST_PLACEHOLDER: mssql-deployment.infra.svc.cluster.local
  BDS_CFG_GLOBALS_GVP_DB_PL_EASTUS2_NAME_PLACEHOLDER: gvp_rs
  BDS_CFG_GLOBALS_GVP_DB_PL_EASTUS2_PSW_PLACEHOLDER: gvp_rs_password
  BDS_CFG_GLOBALS_GVP_DB_PL_EASTUS2_USR_PLACEHOLDER: openshiftadmin
  BDS_CFG_GLOBALS_GVP_DB_PSW_PLACEHOLDER: db_password
  BDS_CFG_GLOBALS_GVP_DB_USER_PLACEHOLDER: openshiftadmin
  BDS_CFG_GLOBALS_GVP_DB_WESTUS2_HOST_PLACEHOLDER: mssql-deployment.infra.svc.cluster.local
  BDS_CFG_GLOBALS_GVP_DB_WESTUS2_NAME_PLACEHOLDER: gvp_rs
  BDS_CFG_GLOBALS_GVP_DB_WESTUS2_PSW_PLACEHOLDER: db_password
  BDS_CFG_GLOBALS_GVP_DB_WESTUS2_USR_PLACEHOLDER: openshiftadmin
  BDS_CFG_GWS_AUTH_HOST_PLACEHOLDER: http://gauth-auth.gauth.svc.cluster.local
  BDS_CFG_GWS_HOST_PLACEHOLDER: http://gws-service-proxy.gws.svc.cluster.local
  BDS_CFG_LEGACY_GLOBALS_SFTP_PSW_PLACEHOLDER: ""
  BDS_CFG_LEGACY_GLOBALS_SFTP_USR_PLACEHOLDER: ""
  BDS_CFG_SFTP_HOST_PLACEHOLDER: ""
  BDS_CFG_SFTP_PATH_PLACEHOLDER: ""
  BDS_CFG_SOURCEID_PLACEHOLDER: MULTICLOUD_PE
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
