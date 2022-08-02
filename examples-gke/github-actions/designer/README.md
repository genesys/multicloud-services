![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)

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
To use the scripting for service deployment, create a deployment secret (`deployment-secrets`) to store confidential information you may not want held in your repository, or `.yaml` files. 
### Notes
The example provided uses the **Blue/Green** strategy. Check out the [documentation](https://all.docs.genesys.com/DES/Current/DESPEGuide/Upgrade) for additional info.

## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
designer_gws_client_id| designer_client
designer_gws_client_secret| secret

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: designer
stringData:
  designer_gws_client_id: designer_client
  designer_gws_client_secret: secret
```

## Upgrade

Designer operates using the **Blue/Green** strategy. [link](https://all.docs.genesys.com/DES/Current/DESPEGuide/Upgrade)

### Upgrade Process:

1. Update the version `chart.ver` as well as the image `image.tag` section within the `override-values.yaml`.
2. As needed, add configuration updates to the release `override-values.yaml` in `0[3,5]_chart-designer[-das]/0[1,2]_release_xxxxxx/override-values.yaml/`.
3. Run action `install` from pipeline
4. Ensure new version works properly. Run through your service checklist and verification.
5. Make cutover (change the active color) using script or manually
6. Run action `install` from pipeline again to reconfiguration `designer ingress` and `designer-das` service


### Upgrade Configuration:
**designer** includes 7 releases within 5 chart folders:

- `01_chart_designer` - installation of shared volumes
- `02_chart_designer` - installation of 2 releases: blue and green designer application
  - `./02_chart_designer/01_release_designer-green/`
  - `./02_chart_designer/02_release_designer-blue/`
- `03_chart_designer` - installation of designer ingress, which is used for cutover
- `04_chart_designer` - installation of 2 releases: blue and green designer-das application
    - `./04_chart_designer-das/01_release_designer-das-green/`
    - `./04_chart_designer-das/02_release_designer-das-blue/`
- `05_chart_designer` - installation designer-das services, which is used for cutover


For your initial setup configurations and versions of `designer` and `designer-das` blue and green release version can be identical, with the exception of deployment color. 
After installation we will have distinct instances: blue and green for each designer application.
```
NAME                	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART                      	APP VERSION  
designer-blue       	designer 	4       	2022-06-20 06:58:40.896990126 +0000 UTC	deployed	designer-100.0.122+1407    	9.0.122.14.14
designer-das-blue   	designer 	4       	2022-06-20 06:58:45.435584372 +0000 UTC	deployed	designer-das-100.0.111+0806	100.0.001.0008 
designer-das-green  	designer 	4       	2022-06-20 06:58:43.748875877 +0000 UTC	deployed	designer-das-100.0.111+0806	100.0.001.0008 
designer-das-service	designer 	4       	2022-06-20 06:58:46.846578072 +0000 UTC	deployed	designer-das-100.0.111+0806	100.0.001.0008 
designer-green      	designer 	4       	2022-06-20 06:58:39.317437654 +0000 UTC	deployed	designer-100.0.122+1407    	9.0.122.14.14
designer-ingress    	designer 	4       	2022-06-20 06:58:42.433632839 +0000 UTC	deployed	designer-100.0.122+1407    	9.0.122.14.14
designer-volume     	designer 	4       	2022-06-20 06:58:37.961794712 +0000 UTC deployed	designer-100.0.122+1407    	9.0.122.14.14
```

**Active color** is defined by override values for designer ingress and designer-das service:

:memo: **These values should be equal.** 

```
    03_chart_designer/override_values.yaml - designer color, value of designer.deployment.color

    05_chart_designer-das/override_values.yaml - designer-das color, value of das.deployment.color
```

### Cutover Script

The included sample script, `cutover.sh`, will flip the color within the charts. 
With `yq` utility installed, it is possible to run this script natively within the designer directory. 
Otherwise, treated the script as a prompt for the cutover operation.
```
| genesys/multicloud-services/designer > ./cutover.sh

Changing designer.deployment.color to new color: <green> in 03_chart_designer/override_values.yaml file...
Changing das.deployment.color to new color: <green> in 05_chart_designer-das/override_values.yaml file...
```


## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).
