[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/IWDDM/?color=orange)](https://all.docs.genesys.com/PEC-IWD/Current/IWDDMPEGuide)


# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-IWD/Current/IWDDMPEGuide) for the full configuration and deployment details.

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
Ingress | | external https access
Cert manager |  | optional, for ingress tls
Consul | |
Kafka | |
REDIS | |
DB Server | :heavy_check_mark: |
Elasticsearch | |

### Genesys service dependency
iWDDM requires the following be installed:
- GAuth
- Nexus (also should be provisioned for current tenant)
- iWD (also should be provisioned for current tenant)

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`deployment_secrets`

:asterisk: Indicates the variable is mandatory.
|:key: Key|:anchor: Default Value|:pencil2: Sample Value| :book: Description|
|:-|:-:|:-|:-|
POSTGRES_ADDR|  $POSTGRES_DGT_ADDR (global DS)
POSTGRES_USER|  (global DS)
POSTGRES_PASSWORD|  (global DS)
TENANT_SID|  (global DS)
:asterisk: iwddm_nexus_api_key |-|
iwddm_db_user|  iwddm-$TENANT_SID
iwddm_db_password |  iwddm-$TENANT_SID 
iwddm_gim_db_addr |  $POSTGRES_RPTHIST_ADDR (global DS)
iwddm_gim_db_name |  gim
iwddm_gim_db_password | gim
iwddm_gim_db_user | gim



An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: iwddm
stringData:
  iwddm_db_user: iwddm-100
  iwddm_db_password: iwddm-100
  iwddm_gim_db_addr: pgdb-rpthist-postgresql.infra
  iwddm_gim_db_name: gim
  iwddm_gim_db_user: gim
  iwddm_db_user: iwddm
  iwddm_nexus_api_key: **from nex_apikeys** iWD 100 t100 IWDDM Key
```

### Notes

`iwddm_nexus_api_key` - assign same value as you defined for iWD `iwd_tenant_api_key_iwddm`

The `iwddm_nexus_api_key` can be taken from the nexus db:
```
 SELECT id,name FROM nex_apikeys;
```


## Monitoring capabilities

iWDDM is periodic cronjob, so it does not provide prometheus endpoints for scraping.
Instead, it pushes prometheus metrics to push gateway, if configured.

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | | 
Servicemonitors CRD | | 
Prometheusrules CRD (Alerts) | | :heavy_check_mark:
Configmaps (grafana) | | :heavy_check_mark:
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).