## Actions-runner-controller

Convenient setup for your self-hosted GitHub runners.

How-to: https://github.com/actions-runner-controller/actions-runner-controller

- Install manually in chosen namespace (eg, "tools") by ```./script.sh```
- Follow instructions in script.

**Important** you need to add `GITHUB_TOKEN` in your deployment secrets, prior to deployment.
Also if using a custom runner image, you need to include a pull secret (`pullsecret`) in deployment namespace, to allow pulling container image from your private repository.

### Custom Runner Image
It is required to build custom runner image (`summerwind/actions-runner:latest`) as the default image does not contain the necessary tool-kit. (e.g. `kubectl`, `helm` ,`oc cli`, etc.)

Provide your artifactory credentials as exported env variables, as well as your docker repo and resulting image version:
```
export JFROG_USER=xxx
export JFROG_TOKEN=yyy
export RUNNER_IMAGE=<docker_repository>/<image_name>
export STAG=0.0.1
```
You can also then run ```./build_runner.sh```

### Deleting
In order to delete deployment, apply commands:
```
helm uninstall actions-runner-controller
kubectl delete secret controller-manager
```