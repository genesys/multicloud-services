[![release](https://flat.badgen.net/github/release/genesys/multicloud-services?color=pink)](https://github.com/genesys/multicloud-services/)
[![license](https://flat.badgen.net/github/license/genesys/multicloud-services?color=blue)](/LICENSE)
[![K8ssupport](https://flat.badgen.net/badge/supported%20K8s%20release/1.22/cyan)](https://all.docs.genesys.com/ReleaseNotes/Current/GenesysEngage-cloud/PrivateEdition)
[![discussions](https://img.shields.io/github/discussions/genesys/multicloud-services?style=flat-square&color=green)](https://github.com/genesys/multicloud-services/discussions)
[![issues](https://flat.badgen.net/github/open-issues/genesys/multicloud-services?color=purple)](https://github.com/genesys/multicloud-services/issues)
[![wiki](https://img.shields.io/badge/wiki-documentation-forestgreen?style=flat-square)](https://github.com/genesys/multicloud-services/wiki)
# Ingress Considerations

When configuring ingresses within an environment there are some specific considerations that need to be addressed.

1. What ingress controller is being used? *e.g. NGINX*
2. Are multiple Controllers deployed? 
2. Is TLS required? 
3. How are you managing ingress certificates in your environment? *e.g. Cert-Manager*
4. How are you signing certificates? *e.g. Self-Managed, LetsEncrypt* 

 Kubernetes supports the use of Multiple Ingress Controllers so you must configure your ingress to use the proper controller. Depending on the conditions above you will need to modify your ingress configuration accordingly.

## NGINX Ingress Controller

*For more info on setting up NGINX Ingress Controllers: https://kubernetes.github.io/ingress-nginx/deploy/* 

Annotations are required to instruct your ingress to use the desired ingress controller: 

- **kubernetes.io/ingress.class** - Instructs Kubernetes which ingress controller to manage ingress 

#### **NOTE** - *if ingress controller is already configured as cluster default this may not be required* 

*See full list of supported annotations here: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/* 


## Cert-Manager

cert-manager allows you to configure and manage signed/self-signed certificates for your Ingress TLS implementation.  

*for info on deploying cert-manager: https://cert-manager.io/docs/installation/* 

Annotations are used to integrate cert-manager config in your ingress

- **cert-manager.io/cluster-issuer** - defines the issuer configured as a CRD in your environment

*for info on Issuer types: https://cert-manager.io/docs/configuration/* 


Ingress TLS Spec

Configuring TLS requires you update ingress spec: 

- **hosts** - defines the fqdn name(s) used when generating ingress certificate
- **secretName** - defines the name of the k8s secret cert-manager will create.   
**NOTE** - *k8s Secret is located in same namespace as the ingress you are creating* 


## Example Ingress yaml 
**Considerations:** 
 - NGINX Ingress Controller
 - TLS is required
 - Cert-manager 
 - CA Issuer type

``` yaml
ApiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  namespace: my-namespace
  annotations:
    cert-manager.io/cluster-issuer: ca-cluster-issuer  # defines configured Issuer CRD
    kubernetes.io/ingress.class: nginx  # defines the ingress controller in the environment 
    nginx.ingress.kubernetes.io/ssl-redirect: 'false'
    nginx.ingress.kubernetes.io/use-regex: 'true'
spec:
  tls:
    - hosts:
        - my-app.$domain  # defines fqdn for ingress cert 
      secretName: my-ingress-cert # defines name of k8s secret that contains cert
  rules:
    - host: my-app.$domain 
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: my-service
                port:
                  name: default
```

* Have a question that you don't see answered in the documentation? - _File an issue_
* Want to know if we're planning on building a particular feature? - _File an issue_
* Have an idea for a new feature? - _File an issue/feature request_
* Don't understand how to do something? - _File an issue_
* Found an existing issue that describes yours? - _upvote and add additional info where applicable_
