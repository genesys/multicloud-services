[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)

# Getting Started
The service directories and scripts needed for CI/CD deployment.

# TL;DR

The service examples :
- Are CI/CD agnostic, and can be used with various pipeline models.
- Include pre-defined defaults.
- Presume monitoring and observability stacks will be used.
- Run out-of-the-box with lab configurations.
- Include CI/CD details to assist with your continued development.
   
# Prerequisites

Before running the service deployment:
- [ ] Familiarize yourself with the CI/CD pipeline model. [GitHub Actions](/doc/gha.md)/[Cloud Build](/doc/cloudbuild.md)    
- [ ] Review the secret methods used with the examples. [Secrets](/doc/secrets.md)
- [ ] Review the scripts used in the deployment. [Scripts](/services#scripts)
- [ ] Review the third-party services. [Third-Party](/third-party/README.md) 


# Deployment

The deployment is defined in a sequential process. This is controlled by the [`deployment.sh`](deployment.sh) script. 
<pre>
└── services
   └── Genesys [service]
      └── 01_chart_[chart-name]
         └── 01_release_[release-name]
             ├── init_db.sh
             ├── pre-release-script.sh
             ├── post-release-script.sh
             └── override_values.yaml
</pre>
## For Every Helm Chart

ℹ️ Within each service application folder exist subfolder(s) with the following format: 
`[0-9][0-9]_chart_chart-name` where `chart-name` is name of chart used to install and where digits define the installation order.

Example of `chart-name` used in command line:
```
helm install release-name helm-repo/chart-name
```


## For Every Helm Release
ℹ️ Within each chart folder exist subfolder(s) with name the following format: 
`[0-9][0-9]_release_release-name` where `release-name` is the name of the release to install and where digits define the installation order. 
Example of `release-name` used in command line:
```
helm install release-name helm-repo/chart-name
```
- If you want to run some preparation scripts (example: initialize database, check conditions) before installing, place the code in `pre-release-script.sh` within the release subfolder.
- If you want to run some post-installion scripts (example: validate conditions), place the code in `post-release-script.sh` within the release subfolder.

## Recommendations
It is recommended to separate your override values for installation and provisioning, as well as maintaining separate files for application versions. This allows easier upgrades.

Helm installation on top of existing services does not impact the service, as Kubernetes applies change and restarts pods only if there is real difference between applied manifest and corresponding k8s object.

## Monitoring
All service deployments include the predefined monitoring configurations. `[0-9][0-9]_chart_[service]-cpe-monitoring`

The capabilities included with each service are detailed in their `README.md`. 

### Monitoring capabilities

Objects | Provided by service Helm chart | Provided by CPE monitoring
|-|:-:|:-:|
Podmonitors CRD | :heavy_check_mark: | 
Servicemonitors CRD | | 
Prometheusrules CRD (Alerts) |  | :heavy_check_mark:
Configmaps (grafana) |  | :heavy_check_mark:
Grafanadashboards CRD | | :heavy_check_mark:
Prometheus annotations (*) | |

# Deployment Order
The standard service deployment order aligns with the [documented](https://all.docs.genesys.com/PrivateEdition/Current/PEGuide/ContDepOrder) order.

<details>
<summary>Service Table</summary>

|Order|Service|Documentation
-|-|-
1|[monitoring](/services/monitoring/)|
2|[logging](/services/logging/)
3|[infra](/services/infra/)
4|[gauth](/services/gauth/)|:book:[documentation](https://all.docs.genesys.com/AUTH/Current/AuthPEGuide/Overview)
5|[voice](/services/voice/)|:book:[documentation](https://all.docs.genesys.com/VM/Current/VMPEGuide/Overview) 
6|[tenant](/services/tenant/)|:book:[documentation](https://all.docs.genesys.com/PrivateEdition/Current/TenantPEGuide)
7|[gws](/services/gws/)|:book:[documentation](https://all.docs.genesys.com/GWS/Current/GWSPEGuide)
8|[wwe](/services/wwe/)|:book:[documentation](https://all.docs.genesys.com/PEC-AD/Current/WWEPEGuide)
9|[webrtc](/services/webrtc/)|:book:[documentation](https://all.docs.genesys.com/WebRTC/Current/WebRTCPEGuide)
10|[gvp](/services/gvp/)|:book:[documentation](https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Overview)
11|[designer](/services/designer/)|:book:[documentation](https://all.docs.genesys.com/DES/Current/DESPEGuide/Overview)
11|[gsp](/services/gsp/)|:book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/GIMPEGuide/Overview) 
12|[gca](/services/gca/)|:book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/GIMPEGuide/Overview) 
13|[gim](/services/gim/)|:book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/GIMPEGuide/Overview) 
14|[ucsx](/services/ucsx/)|:book:[documentation](https://all.docs.genesys.com/UCS/Current/UCSPEGuide) 
15|[nexus](/services/nexus/)|:book:[documentation](https://all.docs.genesys.com/PEC-DC/Current/DCPEGuide)
16|[iwd](/services/iwd/)|:book:[documentation](https://all.docs.genesys.com/PEC-IWD/Current/IWDPEGuide)
17|[iwddm](/services/iwddm/)|:book:[documentation](https://all.docs.genesys.com/PEC-IWD/Current/IWDDMPEGuide)
18|[iwdem](/services/iwdem/)|:book:[documentation](https://all.docs.genesys.com/PEC-Email/Current/EmailPEGuide)
19|[tlm](/services/tlm/)|:book:[documentation](https://all.docs.genesys.com/TLM/Current/TLMPEGuide)
20|[cxc](/services/cxc/)|:book:[documentation](https://all.docs.genesys.com/PEC-OU/Current/CXCPEGuide)
21|[ges](/services/ges/)|:book:[documentation](https://all.docs.genesys.com/PEC-CAB/Current/CABPEGuide) 
22|[pulse](/services/pulse/)|:book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/PulsePEGuide)
23|[ixn](/services/ixn/)|:book:[documentation](https://all.docs.genesys.com/IXN/Current/IXNPEGuide)
24|[bds](/services/bds/)|:book:[documentation](https://all.docs.genesys.com/BDS/Current/BDSPEGuide)
25|[gcxi](/services/gcxi/)|:book:[documentation](https://all.docs.genesys.com/PEC-REP/Current/GCXIPEGuide/Overview)

</details>



# Scripts

### [deployment.sh](deployment.sh)
The common deployment script used by all CI/CD pipelines.  
### [global-defaults.sh](global-defaults.sh)
A set of default variables used for out-of-the-box lab configurations.
### [helpers.sh](helpers.sh)
A set of functions used by the various scripts. 
