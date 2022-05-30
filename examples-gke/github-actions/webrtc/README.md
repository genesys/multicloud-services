# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.

## Prerequisites

n/a

## Configuration

Be sure to update the values defined to align with your environment.

|Option|Value|
|-|-|
|`image.webrtc`|`repository.addrress/webrtc`
|`image.coturn`|`repository.addrress/webrtc`
|`image.webrtcVersion`|`100.0.016.0000`
|`image.coturnVersion`|`100.0.016.0000`
|`gateway.logPvc.storageClassName`|`files-retain`
|`coturn.logPvc.storageClassName`|`files-retain`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`
- `secrets/deployment_secrets`



## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
