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

(Important note: As of 7-30-2020, please do not run README.sh as a script. Instead copy/paste commands into terminal.)

## Post deployment
Once everything has deloyed correctly, you can view/interact with the testnetinabox cluster with a few different tools. 
The Grafana dashboard will provide visual data of peer activities and certain RPCs. The Lens IDE will allow users to connect
to pods and run commands, as the cluster maintains the control-plane. Otherwise, users can issue commands from terminal
to retrieve/interact with zcash data.

### View dashboard
```
kubectl port-forward svc/monitoring 3000:3000 &
```
Browse to http://localhost:3000/d/mIrc97CCz/zcash-testnet-in-a-box

### Tail zcashd pod logs
To tail logs for the first zcash pod:
```
export pod1=$(kubectl get pods -l app=zcash-with-exporter  -o jsonpath="{.items[0].metadata.name}")
export pod2=$(kubectl get pods -l app=zcash-with-exporter  -o jsonpath="{.items[1].metadata.name}")
kubectl logs -f $pod1 -c zcashd-script
```

### Tail zcashd-peer logs
```
kubectl logs -f -l app=zcashd-peers
```

### Zcash RPCs
To run a zcash RPC on `$pod1`:

```
kubectl exec -ti $pod1 -c zcashd-script -- bash
${HOME}/workspace/source/src/zcash-cli -rpcpassword=${ZCASHD_RPCPASSWORD} getinfo
```
See https://zcash-rpc.github.io/ for a list current of Zcash RPCs

### Scaling Pods
As the nodes are modified with their given zcash.confs, users can scale pods to add more peers to the cluster:
```
kubectl scale --replicas=4 deploy/zcash-tnb-bundle
kubectl logs -f $pod1 -c zcashd-script
```
This will create 4 pods in the cluster. This can scale up to N pods depending on your system resources.

### Using Lens IDE
An alternative tool to interact with the cluster is Lens (https://k8slens.dev/):
```
wget https://github.com/lensapp/lens/releases/download/v3.5.1/Lens-3.5.1.AppImage
chmod +x Lens-3.5.1.AppImage
sudo mv Lens-3.5.1.AppImage /usr/sbin/lens
```
Once installed successfully, start Lens and select the cluster from the 'Add clusters' + button in the IDE. This will allow you to interact with the pods from a dashboard. This can be useful when a developer needs to view logs and debug information, for a given set of pods.

### Creating custom bundles
Depending on your network needs, you will likely have a few different zcash.confs to simulate miners and other nodes. 
For details of what goes into a bundle see: https://github.com/zcash-hackworks/zcash-testnet-in-a-box/blob/master/docs/BUILD-zcashd-tnb-artifacts.md 
