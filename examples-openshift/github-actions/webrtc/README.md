![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Configuration

Be sure to update the values defined to align with your environment.

|Option|Value|
|-|-|
|`image.webrtc`|`repository.addrress/webrtc`
|`image.coturn`|`repository.addrress/webrtc`
|`image.webrtcVersion`|`100.0.044.0000`
|`image.coturnVersion`|`100.0.044.0000`
|`gateway.logPvc.storageClassName`|`files-retain`
|`coturn.logPvc.storageClassName`|`files-retain`

To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 
### Notes
The example provided uses the **Blue/Green** strategy. Check out the [documentation](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide/Upgrade) for additional info.

## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

## Upgrade

WebRTC operates using the **Blue/Green** strategy. [link](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide/Upgrade)

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

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
