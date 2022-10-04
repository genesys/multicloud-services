[![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![docs](https://badgen.net/badge/Genesys%20Documentation/NEXUS/orange)](https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide) 

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret `deployment-secrets` to store confidential information you may not want held in your repository, or `.yaml` files. 
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
REDIS | :heavy_check_mark: |
DB Server | :heavy_check_mark: |
Elasticsearch | |

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
LOCATION|  (global DS)
TENANT_SID |  (global DS)
TENANT_UUID | (global DS)
POSTGRES_ADDR |  $POSTGRES_DGT_ADDR (global DS)
POSTGRES_USER | (global DS)
POSTGRES_PASSWORD |  (global DS)
REDIS_ADDR | (global DS) 
REDIS_PORT |  (global DS)
REDIS_PASSWORD |  (global DS)
nexus_db_password|  nexus
nexus_db_user| nexus
:asterisk: nexus_gws_client_id| -|
:asterisk: nexus_gws_client_secret|-|
nexus_tenant_locations|  westus2
nexus_tenant_adm_user| default
nexus_tenant_adm_pass| password


An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: nexus
stringData:
  nexus_gws_client_id: nexus_client
  nexus_gws_client_secret: secret
```



## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | | 
Servicemonitors CRD | :heavy_check_mark: | 
Prometheusrules CRD (Alerts) | :heavy_check_mark: |
Configmaps (grafana) | | :heavy_check_mark:
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | :heavy_check_mark: (on service) |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).


## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).