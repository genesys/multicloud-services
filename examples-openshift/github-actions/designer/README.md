# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/DES/Current/DESPEGuide/Overview) for the full configuration and deployment details.

## TL;DR
- Complete the prequisites if any.
- Adjust the `chart.ver` to the release you wish to deploy.
- Adjust the `override_values.yaml` to suit your environment and needs.
- Create the required secrets.
- Run the github actions workflow.


## Configuration

Be sure to update the values defined to align with your environment.
To use the scripting for service deployment, create a deployment secret (deployment-secrets) to store confidential information you may not want held in your repository, or `.yaml` files. 

- `secrets/pullsecret`
- `secrets/deployment_secrets`

designer
--
|Option|Value|
|-|-|
|`designer.image.repository`| point to your local repository for service images.
|`designer.image.tag`| version of the image to install.
|`designer.image.imagePullSecrets` | adjust to the secret loaded for your repo.
|`designer.designerSecrets.secrets.DES_GWS_CLIENT_ID` | client id used for communications with GWS
|`designer.designerSecrets.secrets.DES_GWS_CLIENT_SECRET` | client secret used for communications with GWS
|`designer.volumes.logsPvc.claimSize`| default 3Gi
|`designer.volumes.logsPvc.storageClass`| adjust to the storageClass of your cluster
|`designer.volumes.workspacePvc.claimSize`| default 3Gi
|`designer.volumes.workspacePvc.storageClass`| adjust to the storageClass of your cluster
|`designer.ingress.hosts`|adjust to the domain of your cluster
|`designer.securityContext.runAsUser`| default 500
|`designer.securityContext.runAsGroup`| default 500
|`designer.securityContext.fsGroup`| default 500
|`designer.securityContext.runAsNonRoot`|default true


das
--
|Option|Value|
|-|-|
|`das.image.repository`| point to your local repository for service images.
|`das.image.tag`| version of the image to install.
|`das.image.imagePullSecrets` | adjust to the secret loaded for your repo.
|`das.securityContext.runAsUser`| default 500
|`das.securityContext.runAsGroup`| default 500
|`das.securityContext.fsGroup`| default 500
|`das.securityContext.runAsNonRoot`|default true


## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).