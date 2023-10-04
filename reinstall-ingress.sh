#!/bin/bash

helm uninstall dev
kubectl delete deployment kibana
kubectl delete service kibana
kubectl delete --ignore-not-found=true -f kube-prometheus-main/manifests/ -f kube-prometheus-main/manifests/setup
kubectl delete pvc --all
docker exec minikube rm -rf /tmp/hostpath-provisioner/default
docker exec minikube sh -c 'chmod -R 777 /tmp/hostpath-provisioner/default' 
minikube addons enable ingress

kubectl apply -f ./secret.yaml
#kubectl apply --server-side -f kube-prometheus-main/manifests/setup
#kubectl wait \
#	--for condition=Established \
#	--all CustomResourceDefinition \
#	--namespace=monitoring
#kubectl apply -f kube-prometheus-main/manifests/

helm repo update
sleep 60
helm install dev camunda/camunda-platform -f separate-ingress-values.yaml
sleep 120

kubectl create -f kibana.yaml
kubectl apply -f kibana-ingress.yaml
#kubectl apply -f grafana-ingress.yaml

kubectl port-forward deployment/dev-zeebe-gateway 8000:8000 &
kubectl port-forward statefulset/dev-zeebe 8001:8000 &
kubectl port-forward deployment/dev-operate 8002:8000 &
kubectl port-forward deployment/dev-tasklist 8003:8000 &

minikube tunnel
