[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/IXN/?color=orange)](https://all.docs.genesys.com/IXN/Current/IXNPEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/IXN/Current/IXNPEGuide) for the full configuration and deployment details.

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
Ingress | | external https access
Cert manager |  | optional, for ingress tls
Consul | :heavy_check_mark: |
Kafka | :heavy_check_mark: |
REDIS | |
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
TENANT_SID |  (global DS) ||Tenant CCID
TENANT_UUID |  (global DS)||Tenant short-id
POSTGRES_ADDR |  $POSTGRES_DGT_ADDR (global DS)||Postgres address for digital
POSTGRES_USER |  (global DS)||Postgres admin account
POSTGRES_PASSWORD |  (global DS)||Postgres admin password
REDIS_ADDR |  (global DS)||REDIS address
KAFKA_ADDR |  (global DS)||Kafka address
ixn_db_name|  ixn-$TENANT_SID|ixn-100|IXN DB name
ixn_node_db_name|  ixn-node-$TENANT_SID|ixn-100|IXN tenant DB name
ixn_db_user | ixn||Username for IXNDB and IXN_NODE_DB
ixn_db_password | ixn||Password for IXNDB and IXN_NODE_DB

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: ixn
stringData:
  ixn_db_name: ixn-100
  ixn_node_db_name: ixn-100
```

## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
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

