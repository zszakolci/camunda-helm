#!/bin/bash

helm uninstall dev
kubectl delete pvc --all
docker exec minikube rm -rf /tmp/hostpath-provisioner/default
docker exec minikube sh -c 'chmod -R 777 /tmp/hostpath-provisioner/default' 
minikube addons enable ingress
minikube addons enable ingress-dns
kubectl apply -f ./secret.yaml

#  d

# kubectl create secret generic dev-c8-combined \
#                       --from-file=tls.crt=/Users/zalanszakolci/Camunda/Camunda_Platform_8_Helm/certificates/dev.c8.combined.crt \
#                       --from-file=tls.key=/Users/zalanszakolci/Camunda/Camunda_Platform_8_Helm/certificates/dev.c8.combined.key

helm repo update
sleep 60
helm install dev camunda/camunda-platform -f separate-ingress-values.yaml
sleep 300
minikube tunnel
