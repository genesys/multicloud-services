[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/Pulse/?color=orange)](https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide) for the full configuration and deployment details.

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
TENANT_UUID|  (global DS)
TENANT_SID|  (global DS)
POSTGRES_ADDR| $POSTGRES_RPTRT_ADDR (global DS)
POSTGRES_USER |  (global DS)
POSTGRES_PASSWORD |  (global DS)
:asterisk: pulse_gws_client_id | -| pulse_client
:asterisk: pulse_gws_client_secret| -| secret
pulse_db_name| pulse
pulse_db_user |  pulse
pulse_db_password |  pulse
pulse_redis_host |  pulse-redis-master
pulse_redis_port |  6379
pulse_redis_key |  secret


Example `.yaml`
```
apiVersion: v1
kind: Secret
metadata:
  name: deployment-secrets
  namespace: pulse
type: Opaque
stringData:
  pulse_gws_client_id: pulse_client
  pulse_gws_client_secret: secret
  pulse_db_name: pulse
  pulse_db_user: pulse
  pulse_db_password: pulse
  pulse_redis_host: pulse-redis-master
  pulse_redis_port: 6379
  pulse_redis_key: secret
```
### Notes
1. Our examples use override value `log.volumeType: none` 

To write logging to storage, please consult with our :book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide).


2. As Pulse supports only non-clustered versions of redis, the example pipeline install includes an non-clustered version for itself. If an non-clustered redis has already been deployed, `pulse_redis_host`, `pulse_redis_port`, and `pulse_redis_key` can be defined within the `deployment_secrets`.


It will be used when defined code in `./pulse/01_chart_init/01_release_pulse-init/pre-release-script.sh` has been deleted or commented.  

## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD |:heavy_check_mark: | 
Servicemonitors CRD | :heavy_check_mark: | 
Prometheusrules CRD (Alerts) |  |:heavy_check_mark:
Configmaps (grafana) | | :heavy_check_mark:
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) |  |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
