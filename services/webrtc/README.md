[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
[![docs](https://flat.badgen.net/badge/Genesys%20Documentation/WebRTC/?color=orange)](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide)

# Getting Started
We've included a basic deployment to help get started.

Consult with our :book:[documentation](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prerequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the workflow.

## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 

### Notes
The example provided uses the **Blue/Green** strategy. Check out the :book:[documentation](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide/Upgrade) for additional info.

## Prerequisites
### Cluster resources

Following cluster resources and services are required:

Resources | Required | Purpose
|-|:-:|-|
Persistent Storage | | 
Ingress | :heavy_check_mark: | external https access
Cert manager | :heavy_check_mark: | optional, for ingress tls
Consul |  |
Kafka |  |
REDIS |  |
DB Server |  |
Elasticsearch |  |




### Secrets 
Create the standard [pullsecret](/doc/secrets.md/#pull) for the workflow: 
`pullsecret`

:book: WebRTC service does not require any specific parameters in `deployment-secrets`.
It uses standard globally defined variables such as  `$DOMAIN`, `$IMAGE_REGISTRY`, or `$INGRESS_CLASS`.

## Upgrade

WebRTC operates using the **Blue/Green** strategy. [Learn more here.](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide/Upgrade)

### Upgrade Process:

1. Update the version `chart.ver` as well as the image `image.tag` section within the `override-values.yaml`.
2. As needed, add configuration updates to the release `override-values.yaml` in `01_chart_webrtc-service/0[3,4]_release_webrtc-[coturn,gateway]-[blue,green]/override-values.yaml/`.
3. Run action `install` from pipeline
4. Ensure new version works properly. Run through your service checklist and verification.
5. Make cutover (change the active color) using script or manually
6. Run action `install` from pipeline again to reconfiguration `webrtc-ingress` service


### Upgrade Configuration:
**webRTC** includes 5 releases within 1 chart folder:

- `01_release_webrtc-infra` - baseline of webRTC-infra
- `02_release_webrtc-infra-blue` - installation of 2 releases: blue and green 
- `02_release_webrtc-infra-green` - installation of 2 releases: blue and green 
- `03_release_webrtc-coturn-blue` - installation of 2 releases: blue and green
- `03_release_webrtc-coturn-green` - installation of 2 releases: blue and green
- `04_release_webrtc-gateway-blue` - installation of 2 releases: blue and green
- `04_release_webrtc-gateway-green` - installation of 2 releases: blue and green
- `05_release_webrtc-ingress` - used for cutover


For your initial setup configurations and versions of blue and green release versions can be identical, with the exception of deployment color. 
After installation we will have distinct instances: blue and green for each application.

**Active color** is defined by override values for webrtc ingress service:

:memo: **These values should be equal.** 

```
    02_release_webrtc-infra-blue/override_values.yaml - webRTC color, value of deployment.color

    03_release_webrtc-coturn-blue/override_values.yaml - coturn color, value of deployment.color

    04_release_webrtc-gateway-blue/override_values.yaml - gateway color, value of deployment.color
```

### Cutover Script

The included sample script, `cutover.sh`, will flip the color within the charts. 
With `yq` utility installed, it is possible to run this script natively within the webRTC directory. 
Otherwise, treat the script as a prompt for the cutover operation.
```
| genesys/multicloud-services/webrtc > ./cutover.sh

Changing deployment.color to new color: <green> in 01_chart_webrtc-service/05_release_webrtc-ingress/override_values.yaml file...
```

## Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | :heavy_check_mark: | 
Servicemonitors CRD | | 
Prometheusrules CRD (Alerts) | :heavy_check_mark: (metrics for gateway only) | 
Configmaps (grafana) | :heavy_check_mark: | 
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | |

(*) can be annotations of pods or services. Your Prometheus operator should be configured to scrape those annotations (disabled by default).

## Additional Information

Our sample configurations include the optional monitoring capabilities. 

Secret definitions details - [secret](/doc/secrets.md)

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).

Our sample configurations segment databases as per [database details](/doc/DATABASE.md).
