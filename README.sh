#!/bin/bash
set -eo pipefail # Bail on any errors
set -x           # Echo the command to execute before running it

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

kubectl wait --for=condition=ready pods --selector app=minio --timeout=300s

kubectl create -f tekton/tasks/create-minio-buckets.yml

