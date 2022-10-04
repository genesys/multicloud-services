 [![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![docs](https://badgen.net/badge/Genesys%20Documentation/GES/orange)](https://all.docs.genesys.com/PEC-CAB/Current/CABPEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-CAB/Current/CABPEGuide) for the full configuration and deployment details.

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

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

### Notes
GES works only with unclustered Redis. We've included `01_chart_redis` to include this in the installation process.
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
REDIS | :heavy_check_mark: | unclustered
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
POSTGRES_ADDR |(global DS)
POSTGRES_USER |(global DS)
POSTGRES_PASSWORD |(global DS)
:asterisk: ges_redis_password| - | secret
ges_redis_ors_host| redis-ors-stream.service.$CONSUL_DC_LOCATION.consul
ges_redis_ors_password| (fetches from `redis-config-token` secret in voice)
:asterisk: ges_gws_client_id| -| ges_client
:asterisk: ges_gws_client_secret| - | secret
ges_db_name|   ges
ges_db_password|   ges
ges_db_user|   ges
ges_devops_username|   admin
ges_devops_password|   letmein

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
  ges_redis_password: secret
  ges_gws_client_id: ges_client
  ges_gws_client_secret: secret
  ges_db_name: ges
  ges_db_password: ges
  ges_db_user: ges
  ges_devops_username: admin
  ges_devops_password: letmein
```



## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|-|-|
Podmonitors CRD | | 
Servicemonitors CRD | :heavy_check_mark: | 
Prometheusrules CRD (Alerts) | | :heavy_check_mark:
Configmaps (grafana) | :heavy_check_mark: |
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | :heavy_check_mark: (on services) |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
