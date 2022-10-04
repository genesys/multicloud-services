[![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![docs](https://badgen.net/badge/Genesys%20Documentation/GCXI/orange)](https://all.docs.genesys.com/PEC-REP/Current/GCXIPEGuide/Overview)
# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/GCXIPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Genesys service dependency
iWDDM requires installed:
- GAuth
- GWS
- Voice
- GIM
- iWD & iWDDM

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

### Notes
:memo: Optionally, **gcxi** deployment can be populated with `deployment secrets` of **gim**, and **iwd** in their corresponding namespaces to automatically connect to their databases. See the `pre-release-script.sh` for more details.
## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | | 
Ingress | :heavy_check_mark: | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka | |
REDIS | |
DB Server | :heavy_check_mark: |
Elasticsearch | |


### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

This is list of used variables. You can define via Deployment Secrets (DS).

 :asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
TENANT_SID|  (global DS)
TENANT_UUID|  (global DS)
LOCATION|  (global DS)
POSTGRES_USER |  (global DS)
POSTGRES_PASSWORD|  (global DS)
gcxi_gws_client_id |  gcxi_client
gcxi_gws_client_secret |  secret
gcxi_db_host|  $POSTGRES_RPTHIST_ADDR (global DS)
gcxi_gim_db_host|  $POSTGRES_RPTHIST_ADDR (global DS)
gcxi_gim_db_name|  gim
gcxi_gim_db_user|  gim|gimuser
gcxi_gim_db_pass|  gim|gimpass
gcxi_iwd_db_host|  $POSTGRES_DGT_ADDR (global DS)
gcxi_iwd_db_name|  iwddm-100
gcxi_iwd_db_user|  iwddm-100
gcxi_iwd_db_pass|  iwddm-100


Example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: gcxi
stringData:
  gcxi_gws_client_id : gcxi_client
  gcxi_gws_client_secret : secret
  gcxi_db_host: pgdb-rpthist-postgresql.infra
  gcxi_gim_db_host: pgdb-rpthist-postgresql.infra
  gcxi_gim_db_name: gim
  gcxi_gim_db_user: gimuser
  gcxi_gim_db_pass: gimpass
  gcxi_iwd_db_host: pgdb-dgt-postgresql.infra
  gcxi_iwd_db_name: iwddm-100
  gcxi_iwd_db_user: iwddm-100
  gcxi_iwd_db_pass: iwddm-100
```


## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | | 
Servicemonitors CRD | :heavy_check_mark: | 
Prometheusrules CRD (Alerts) | :heavy_check_mark: | 
Configmaps (grafana) | :heavy_check_mark: |
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | :heavy_check_mark: (on services) |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrale those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
