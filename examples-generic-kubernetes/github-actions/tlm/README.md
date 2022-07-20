![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](all.docs.genesys.com/TLM/Current/TLMPEGuide) for the full configuration and deployment details.

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


## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
TELEMETRY_AUTH_CLIENT_ID| gws-app-workspace
TELEMETRY_AUTH_CLIENT_SECRET| secret

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: tlm
stringData:
  TELEMETRY_AUTH_CLIENT_ID: gws-app-workspace
  TELEMETRY_AUTH_CLIENT_SECRET: secret
```


## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).