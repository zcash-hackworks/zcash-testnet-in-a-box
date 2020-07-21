#!/bin/bash
#set -eo pipefail # Bail on any errors
#set -x           # Echo the command to execute before running it

kind delete cluster --name zcash-testnet-in-a-box || true
kind create cluster --name zcash-testnet-in-a-box
kubectl cluster-info

kubectl apply -f tekton/releases/tekton-pipelines-v0.13.2.yml
kubectl apply -f tekton/releases/tekton-dashboard-v0.7.0.yml
kubectl apply -f tekton/serviceAccount.yml

kubectl create -f tekton/tasks/create-minio-secret.yml
kubectl create -f tekton/tasks/create-zcashrpc-secret.yml
kubectl create -f tekton/tasks/create-monitoring-grafana-admin-secret.yml

kubectl apply -f minio/minio-standalone-pvc.yaml
kubectl apply -f minio/minio-standalone-service.yaml
kubectl apply -f minio/minio-standalone-deployment.yaml
sleep 10
kubectl wait --for=condition=ready pods --selector app=minio --timeout=300s
########################################################################################

kubectl create -f tekton/tasks/create-minio-buckets.yml

kubectl apply -f monitoring/configmap.yml
kubectl apply -f monitoring/service.yml
kubectl apply -f monitoring/serviceaccount.yml
kubectl apply -f monitoring/statefulset.yml
kubectl create configmap grafana-dashboard-zcash-tnb --from-file=./monitoring/grafana-dashboard-zcash-tnb.json

kubectl apply -f deploy/configmaps-tnb.yml

kubectl create -f tekton/tasks/import-zcash-params.yml
kubectl create -f tekton/tasks/import-zcash-tnb-files.yml
sleep 10
kubectl wait --for=condition=Succeeded taskruns -l import=zcash-tnb-bundle  --timeout=6000s
########################################################################################

kubectl apply -f deploy/zcash-tnb-bundle-deploy.yml
kubectl apply -f deploy/zcash-peers.yml
sleep 10
kubectl wait --for=condition=ready pods --selector version=zcash-tnb-bundle --timeout=300s
########################################################################################

export pod1=$(kubectl get pods -l app=zcash-with-exporter  -o jsonpath="{.items[0].metadata.name}")
export pod2=$(kubectl get pods -l app=zcash-with-exporter  -o jsonpath="{.items[1].metadata.name}")

# Watch the logs for zcashd to start
kubectl logs -f $pod1 -c zcashd-script
# `CreateNewBlock(): total size 1000`? GTG
# Don't get it in 5 minutes, failed!

# Get the IPs
# kubectl get pods -l version=zcash-tnb-bundle  -o jsonpath="{.items[*].status.podIP}"
# kubectl exec -ti $pod1 -c zcashd-script -- bash
## IN POD1
# ip a
## EDIT POD2's IP in this line and peer them
# ${HOME}/workspace/source/src/zcash-cli -rpcpassword=${ZCASHD_RPCPASSWORD} addnode "10.244.0.40:18233" "add"
