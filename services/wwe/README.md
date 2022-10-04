 [![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
 [![docs](https://badgen.net/badge/Genesys%20Documentation/WWE/orange)](https://all.docs.genesys.com/PEC-AD/Current/WWEPEGuide)
# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/PEC-AD/Current/WWEPEGuide) for the full configuration and deployment details.

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
DB Server | |
Elasticsearch | |

### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

:book: WWE service does not require any specific parameters in `deployment-secrets`.
It uses standard globally defined variables such as  `$DOMAIN`, `$IMAGE_REGISTRY`, or `$INGRESS_CLASS`.


## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | | 
Servicemonitors CRD | | 
Prometheusrules CRD | |
Configmaps (grafana) | :heavy_check_mark: |
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).



## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
