# Testnet in a box

TNB (testnet-in-a-box) will deploy a collection of monitored and peered zcashd instances to a Kubernetes cluster.

A deployment requires 2 tar archives:
- An archive of binaries from a TNB build (zcashd, zcash-cli, zcash-gtest, zcash-tx) see the task for more info: [./tekton/tasks/build-binary-tnb.yml](./tekton/tasks/build-binary-tnb.yml)
- An archive of a block snapshot from the regular testnet, see the task for more info: [./tekton/tasks/snapshot-gcp.yml](./tekton/tasks/snapshot-gcp.yml)

The versions and source of these archives is defined in `deploy/configmaps-tnb.yml`

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: zcash-tnb-bundle
data:
  ARCHIVE_NAME: zcashd-tnb-artifacts-d292376.tgz
  ARCHIVE_HTTP_SRC: https://gateway.pinata.cloud/ipfs/QmemvQmN8bdqH2S7EZQ3hCXsmoGbTXNcN5vaL98CVQ2yXv
  SNAPSHOT_NAME: zcash-testnet-miner-1009419.tgz
  SNAPSHOT_HTTP_SRC: https://gateway.pinata.cloud/ipfs/QmZwuN84PVBKqZQV1kuJSCvYX9L31vh2PJAA2129wdrZ37
```

## Deployment

Install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)  
See [./README.sh](./README.sh)

## Post deployment

### Tail a zcashd pod logs
```
export pod1=$(kubectl get pods -l app=zcash-with-exporter  -o jsonpath="{.items[0].metadata.name}")
export pod2=$(kubectl get pods -l app=zcash-with-exporter  -o jsonpath="{.items[1].metadata.name}")
kubectl logs -f $pod1 -c zcashd-script
```

### Tail the zcashd-peer logs
```
kubectl logs -f -l app=zcashd-peers
```

### View dashboard
```
kubectl port-forward svc/monitoring 3000:3000 &
```
Browse to http://localhost:3000/d/mIrc97CCz/zcash-testnet-in-a-box
