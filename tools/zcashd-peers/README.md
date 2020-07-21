# zcashd-peers

zcashd-peers is software designed to run inside a kubernetes cluster and coordinate pods running zcashd and match defined labels.

## About

There are no options yet, so you have to edit the code.

The following constants in `main.go` refer to the Kubernetes objects.
```
const labelName = "app"
const labelValue = "zcash-with-exporter"
const namespace = "default"
const configMapName = "zcashd-testnet-miner-config"
const rpcSecretName = "zcashd-rpc"
```


- `labelName` The label name to match on Pods
- `labelValue` Corresponding label value to match
- `namespace` Which namespace to look for Pods
- `configMapName` The configmap zcashd-peers should use to authenticate to the pods (Make it the same one the pods are using!)
- `rpcSecretName` The name of the secret containing the RPC password for the Pods.

For example ConfigMaps and Pod Deployments, checkout https://github.com/zcash-hackworks/zcash-testnet-in-a-box/tree/master/deploy

## Building

Build and push a docker image to an image repository the kubernets cluster has access to.

```
docker build . -t <yourRepo>/zcashd-peers
docker push <yourRepo>/zcashd-peers
```

## Deplot

Edit the `kubernetes/kustomization.yml` to match your image name.

Deploy with

```
kubectl apply -k kubernetes/
```

This will create the required ServiceAccount, Roles, and Deployment for  `zcashd-peers`.