#!/bin/bash
#set -eo pipefail # Bail on any errors
#set -x           # Echo the command to execute before running it

kind delete cluster --name zcash-testnet-in-a-box || true
kind create cluster --name zcash-testnet-in-a-box
kubectl cluster-info

kubectl apply -f tekton/releases/tekton-pipelines-v0.13.2.yml
kubectl apply -f tekton/releases/tekton-dashboard-v0.7.0.yml
kubectl apply -f tekton/serviceAccount.yml

kubectl create -f tekton/tasks/create-zcashrpc-secret.yml
kubectl create -f tekton/tasks/create-monitoring-grafana-admin-secret.yml

kubectl apply -f ipfs/stateful-set.yml
kubectl apply -f monitoring/configmap.yml
kubectl apply -f monitoring/service.yml
kubectl apply -f monitoring/serviceaccount.yml
kubectl apply -f monitoring/statefulset.yml

kubectl create configmap grafana-dashboard-zcash-tnb --from-file=./monitoring/grafana-dashboard-zcash-tnb.json

kubectl apply -f deploy/configmaps-tnb.yml
kubectl apply -f tekton/tasks/ipfs-pin-cid.yml
kubectl create -f tekton/tasks/import-zcash-params-ipfs.yml
kubectl create -f tekton/tasks/import-zcash-tnb-artifacts-ipfs.yml 
kubectl create -f tekton/tasks/import-zcash-snapshot-ipfs.yml

sleep 10
kubectl wait --for=condition=Succeeded taskruns -l import=zcash-snapshot-ipfs  --timeout=6000s

## Taking forever? Add a peer that has these CIDs
# Expose the port for IPFS API locally
kubectl port-forward svc/ipfs-cache 5001:5001

# Download the ipfs binary from https://dist.ipfs.io/#go-ipfs
# Use it to connect the ipfs-cache to a peer (this is one I set up)
# If you change port numbers, use the ipfs --api flag to specify the endpoint
ipfs swarm connect  /ip4/192.241.134.110/tcp/4001/p2p/QmVgxJPDHLXZ3rTiuFHjByDbGCfEDSE5EJPTwYwanxUv3e 
