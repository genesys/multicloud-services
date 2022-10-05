[![license](https://badgen.net/badge/license/MIT/blue)](/tools/configurator/LICENSE) [![version](https://badgen.net/badge/version/1.0.0/green)](/tools/configurator/VERSION) 
# pe-configurator

## Purpose

This script is intended to simplify configuration for deploying https://github.com/genesys/multicloud-services.

The main objective is to prompt for common secrets, provide a basic description for each option, and offer a reasonable working default suitable for a lab.

## Prerequisites

### Basic assumptions

1. You are deploying Genesys services into their own namespaces as per our [publicly documented recommendations](https://all.docs.genesys.com/PrivateEdition/Current/PEGuide/ConfigNamespace).

### "Default" infrastructure assumptions

- Consul is in the consul, or infra namespace
- ElasticSearch is in the infra namespace
- Redis: 
    - clustered, 6.x.x is in the infra namespace
    - non-clustered, 6.x.x is in the pulse namespace
- Postgres is in the infra namespace
    - Postgres is split out into 6 statefulsets, and has been configured as per [our database doc](/doc/DATABASE.md)
- MSSQL is in the infra namespace (for GVP Reporting Server)
- Kafka is in the infra or kafka namespace


## How to customize:

We recommend setting up a custom `dictionary.json`, with the values you need for each environment, then just swap it out as necessary. There is a backup of the original `descriptions.json` and `dictionary.json` should you need to refer back to them or replace them if they become unrecoverable for any reason.

## How to install and run:

1. This script assumes you are using **Python 3.10** or above (for PEP-634 compatibility).
2. Install pip:

Linux or Mac OS:

```bash
curl -sS https://bootstrap.pypa.io/get-pip.py | python3
```
or
```bash
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
```

Windows:
- Download https://bootstrap.pypa.io/get-pip.py
- From the Windows command line, in the directory where get-pip.py is located, run:
    - python get-pip.py

3. After pip is installed, run pip against the `requirements.txt` to install the pre-requisite libraries: 
```bash:
pip install -r requirements.txt
```
4. Run python (Windows) or python3.10 (Linux or WSL) against `app.py`:
```bash
python3.10 app.py
```
5. Follow the prompts
6. Generated yaml, and json files will be in the output folder. You can then run the following to setup the deployment-secrets into their respective namespaces.

For 'entire environments' (`option 2`):

```bash
kubectl apply -f deployment-secrets.yaml
```

For 'individual service' (`option 1`):

```bash
kubectl apply -f $SERVICE/deployment-secrets.yaml
```
