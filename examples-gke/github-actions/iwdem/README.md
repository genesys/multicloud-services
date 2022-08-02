![K8ssupport](https://badgen.net/badge/supported%20K8s%20release/1.22/cyan)
# Getting Started
We've included a basic deployment to help get started.
Consult with our [documentation](all.docs.genesys.com/PEC-Email/Current/EmailPEGuide) for the full configuration and deployment details.

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
`iwdem_nexus_api_key` should be created using nexus API.
*You will be using your own unique tenant UUID and gauth client_id*

```
# Acquire bearer token
curl --location --request POST 'https://gauth.apps.<domain>/auth/v3/oauth/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--header 'Authorization: Basic ***' \
--data-urlencode 'username=***' \
--data-urlencode 'client_id=external_api_client' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'password=***'
```
```
# Acquire nexus API key 
curl --location --request POST 'https://nexus.<domain>/nexus/v3/apikeys' \
--header 'Authorization: Bearer ***token***' \
--header 'Content-Type: application/json' \
--header 'Cookie: ***cookie***' \
--data-raw '{"data": {
"enabled": true,
"tenant": "9350e2fc-a1dd-4c65-8d40-1f75a2e080dd",
"name": "IWDEM API key for t100",
"permissions": [
"nexus:consumer:*"
]}}'
```
## Secrets 
Create the standard [pullsecret](../#-considerations) for the workflow: 
`secrets/pullsecret`

Create the following secrets to store confidential information you may not want held in your repository, or `.yaml` files. 
`secrets/deployment_secrets`

|Key|Sample Value|
|-|-|
iwdem_nexus_api_key| **as generated** 565c12cb-cdae-4141-881d-c91cd55082c2
iwdem_redis_password| redPass

An example `.yaml`
```
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: deployment-secrets
  namespace: iwdem
stringData:
  iwdem_nexus_api_key: **as generated** 565c12cb-cdae-4141-881d-c91cd55082c2
  iwdem_redis_password: redPass
```

## Additional Information

Our sample configurations include the optional monitoring capabilities. For implementation of dashboards and monitoring see the [tools section](/tools).

Be sure to check your ingress details as per [ingress documentation](/doc/ingress.md).