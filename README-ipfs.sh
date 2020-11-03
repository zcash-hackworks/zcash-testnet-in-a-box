#!/bin/bash
#set -eo pipefail # Bail on any errors
#set -x           # Echo the command to execute before running it

kind delete cluster --name zcash-testnet-in-a-box || true
kind create cluster --name zcash-testnet-in-a-box
kubectl cluster-info

kubectl apply -f bases/tekton/releases/tekton-pipelines-v0.13.2.yml
kubectl apply -f bases/tekton/releases/tekton-dashboard-v0.7.0.yml

kubectl apply -k bases/

## Deploy dashboard
kubectl create configmap grafana-dashboard-zcash-tnb --from-file=./bases/monitoring/grafana-dashboard-zcash-tnb.json

# Finish tasks I can't automate yet
kubectl create -f taskruns/create-zcashrpc-secret.yml
kubectl create -f taskruns/create-monitoring-grafana-admin-secret.yml

# Populate IPFS
kubectl create -f taskruns/import-zcash-params-ipfs.yml
kubectl create -f taskruns/import-zcash-tnb-artifacts-ipfs.yml 
kubectl create -f taskruns/import-zcash-snapshot-ipfs.yml


## Watch the taskrun statuses (ctl-c to cancel watching)
kubectl get taskruns -w
# This should  eventually return something like
# NAME                                    SUCCEEDED   REASON    STARTTIME   COMPLETIONTIME
# create-secret-ncjgb                     Unknown     Pending   28s         
# create-secret-p6g49                     Unknown     Pending   27s         
# import-zcash-params-ipfs-wlqtx          Unknown     Running   24s         
# import-zcash-snapshot-ipfs-pj76d        Unknown     Running   23s         
# import-zcash-tnb-artifacts-ipfs-22vdz   Unknown     Running   24s         
# import-zcash-tnb-artifacts-ipfs-22vdz   True        Succeeded   30s         0s
# create-secret-p6g49                     Unknown     Running     87s         
# create-secret-ncjgb                     Unknown     Running     88s         
# create-secret-ncjgb                     True        Succeeded   91s         0s
# create-secret-p6g49                     True        Succeeded   90s         0s

# Use a wait command for scripting
kubectl wait --for=condition=Succeeded taskruns -l import=zcash-snapshot-ipfs  --timeout=6000s

## Taking forever? Add a peer that has these CIDs
# Expose the port for IPFS API locally
# kubectl port-forward svc/ipfs-cache 5001:5001

# Download the ipfs binary from https://dist.ipfs.io/#go-ipfs
# Use it to connect the ipfs-cache to a peer (this is one I set up)
# If you change port numbers, use the ipfs --api flag to specify the endpoint
# ipfs swarm connect  /ip4/192.241.134.110/tcp/4001/p2p/QmVgxJPDHLXZ3rTiuFHjByDbGCfEDSE5EJPTwYwanxUv3e 

# Checking on status

## Open a port to the Grafana dashboard
kubectl port-forward svc/monitoring 0.0.0.0:3000:3000 &

# View the logs of BOTH deployed miners
kubectl logs -l "app=zcash-with-exporter" -c zcashd-script -f
# Specific instances have random names, you'll have to pick on pod to view it in isolation

# View the peering process for errors
kubectl logs -l "app=zcashd-peers"
