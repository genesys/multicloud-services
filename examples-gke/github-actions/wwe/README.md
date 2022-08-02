![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](https://all.docs.genesys.com/PEC-AD/Current/WWEPEGuide) for the full configuration and deployment details.

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

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
- `secrets/pullsecret`

## Usage

Document how to verify service once it has been installed and configured.

## Note
Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools)

## Additional Information

Be sure to check your ingress details as per [ingress documentation.](/doc/ingress.md) 