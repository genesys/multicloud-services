[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/UCS/?color=orange)](https://all.docs.genesys.com/UCS/Current/UCSPEGuide)
# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/UCS/Current/UCSPEGuide) for the full configuration and deployment details.

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

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | | 
Ingress | :heavy_check_mark: | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka | |
REDIS | |
DB Server | :heavy_check_mark: |
Elasticsearch | :heavy_check_mark: |

### Genesys service dependency
UCSX requires installed:
- GAuth
- GWS
- Voice
- Tenant

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-:|:-|
:asterisk: ucsx_gws_client_id | - | ucsx_client|Client ID for communicating with GWS service
:asterisk: ucsx_gws_client_secret| - | secret|Client ID secret
ucsx_db_name| ucsx||Postgres DB name for UCSX
ucsx_tenant_100_db_name|  ucsx_t100||Postgres DB name for UCSX tenant
ucsx_tenant_100_db_password|  ucsx||Postgres DB password for UCSX tenant
ucsx_tenant_100_db_user|  ucsx_t100||Postgres DB user for UCSX tenant


An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
stringData:
  ucsx_gws_client_id: ucsx_api_client
  ucsx_gws_client_secret: secret
  ucsx_db_name: ucsx
  ucsx_tenant_100_db_name: ucsx_t100
  ucsx_tenant_100_db_password: ucsx
  ucsx_tenant_100_db_user: ucsx_t100
```

### Notes

1. For provisioning multi-tenant implementations, add additional tenant release charts. 
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



## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | :heavy_check_mark: | 
Servicemonitors CRD | | 
Prometheusrules CRD (Alerts) | :heavy_check_mark: |
Configmaps (grafana) | :heavy_check_mark: |
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
