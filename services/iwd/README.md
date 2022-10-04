 [![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
 [![docs](https://badgen.net/badge/Genesys%20Documentation/IWD/orange)](https://all.docs.genesys.com/PEC-IWD/Current/IWDPEGuide)


# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-IWD/Current/IWDPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpoose
|-|:-:|-|
Persistent Storage | | 
Ingress |  | external https access
Cert manager |  | optional, for ingress tls
Consul |  |
Kafka |  |
REDIS | :heavy_check_mark: |
DB Server | :heavy_check_mark: |
Elasticsearch |  |

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
TENANT_SID|  (global DS)
TENANT_UUID|  (global DS)
POSTGRES_ADDR | $POSTGRES_DGT_ADDR (global DS)
POSTGRES_USER | (global DS)
POSTGRES_PASSWORD | (global DS)
REDIS_ADDR  | (global DS)
REDIS_PASSWORD | (global DS)
iwd_db_name | iwd-${TENANT_SID}
iwd_db_user | iwd-${TENANT_SID}
iwd_db_password | iwd-${TENANT_SID}
:asterisk: iwd_gws_client_id |-|iwd_client
:asterisk: iwd_gws_client_secret | -| secret
:asterisk: iwd_nexus_api_key| -| `96b0802b-799f-4f55-8d98-ba51eadf75df`
:asterisk: iwd_tenant_api_key| -| `86bcbc3c-0cbd-4b57-845e-299182462079`
:asterisk: iwd_tenant_api_key_iwddm| -| `20993434-e6fb-4081-9b1f-5c5a7e523077`
:asterisk: iwd_tenant_api_key_tenant| -| `e0c519c2-a9d5-48cc-8da9-8566fcce6575`

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: iwd
stringData:
  iwd_gws_client_id: iwd_client
  iwd_gws_client_secret: secret
  iwd_nexus_api_key: 96b0802b-799f-4f55-8d98-ba51eadf75df
  iwd_tenant_api_key: 86bcbc3c-0cbd-4b57-845e-299182462079
  iwd_tenant_api_key_iwddm: 20993434-e6fb-4081-9b1f-5c5a7e523077
  iwd_tenant_api_key_tenant: e0c519c2-a9d5-48cc-8da9-8566fcce6575
```
### Notes
- Nexus should be installed and provisioned for current tenant.
- `iwd_nexus_api_key` should be assined value from Nexus DB, nex_apikeys table, name "iWD Cluster API Key"
- `iwd_tenant_api_key` should be assined value from Nexus DB, nex_apikeys table, name like "t100"
- `iwd_tenant_api_key_iwddm` should be assigned new generated UUID
- `iwd_tenant_api_key_tenant` should be assigned new generated UUID


The `iwd_nexus_api_key` and `iwd_tenant_api_key` are taken from the nexus db:
```
 SELECT id,name FROM nex_apikeys;
```
The `iwd_tenant_api_key_iwddm` and `iwd_tenant_api_key_tenant` can be manually generated in any online UUID generator or in shell:
```
echo  "$(uuidgen)" | tr '[:upper:]' '[:lower:]')
```



## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | | 
Servicemonitors CRD |  | 
Prometheusrules CRD (Alerts) | | 
Configmaps (grafana) |  |
Grafanadashboards CRD | | 
Prometheus annotations (*) |  (on services) |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).