[![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![docs](https://badgen.net/badge/Genesys%20Documentation/BDS/orange)](https://all.docs.genesys.com/BDS/Current/BDSPEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/BDS/Current/BDSPEGuide) for the full configuration and deployment details.

**Note:** latest BDS helm chart requires kubernetes version 1.22+

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret `deployment-secrets` to store confidential information you may not want held in your repository, or `.yaml` files. 
## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage |  | 
Ingress |  | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka | |
REDIS |  |
DB Server | :heavy_check_mark: |
Elasticsearch |  |

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:warning: The BDS configuration file is `bds-manual-secrets.yaml` in `00_init` subfolder.
Typically it does not require updating, but pay attention to the variables used within.

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
|POSTGRES_ADDR | - | $POSTGRES_RPTHIST_ADDR (global DS)| Postgres DB address
:asterisk: bds_gws_client_id |   - | bds_client| Client ID for GWS communication
:asterisk: bds_gws_client_secret   | - | secret| Client secret
:asterisk: bds_sftp_host |   - | 10.10.12.12| SFTP server address
:asterisk: bds_sftp_path |   - |/sftp/bds|
:asterisk: bds_sftp_user |   - | demo | SFTP username
:asterisk: bds_sftp_pass |  - | demo | SFTP password


Example `.yaml`

```
apiVersion: v1
kind: Secret
metadata:
  name: deployment-secrets
  namespace: bds
type: Opaque
stringData:
  bds_gws_client_id: bds_client
  bds_gws_client_secret: <secret>
  bds_sftp_host: x.x.x.x
  bds_sftp_path: /sftp/bds
  bds_sftp_user: demo
  bds_sftp_pass: demo
```

## Acceptance testing

Run test job and check that there are no errors in log
```
kubectl create job --from=cronjob/bds-t100-100 bds-test
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).

