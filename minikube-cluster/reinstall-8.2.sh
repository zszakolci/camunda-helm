#!/bin/bash

minikube profile c8.2
kubectl delete namespace camunda
helm uninstall dev
kubectl create namespace camunda
kubens camunda
#kubectl delete --ignore-not-found=true -f kube-prometheus-main/manifests/ -f kube-prometheus-main/manifests/setup
kubectl delete pvc --all
docker exec c8.2 rm -rf /tmp/hostpath-provisioner/camunda
#docker exec minikube sh -c 'chmod -R 777 /tmp/hostpath-provisioner/camunda' 
# minikube addons enable ingress

kubectl apply -f ./secret.yaml
# kubectl apply --server-side -f kube-prometheus-main/manifests/setup
# kubectl wait \
# 	--for condition=Established \
# 	--all CustomResourceDefinition \
# 	--namespace=monitoring
# kubectl apply -f kube-prometheus-main/manifests/

#helm repo update
#sleep 60
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
helm install dev camunda/camunda-platform --namespace camunda --version 8.2 -f values/separate-ingress-values-8.2.yaml
sleep 60

kubectl create -f kibana-8.2.yaml
kubectl apply -f kibana-ingress.yaml

kubectl port-forward deployment/dev-zeebe-gateway 8000:8000 &
kubectl port-forward statefulset/dev-zeebe 8001:8000 &
kubectl port-forward deployment/dev-operate 8002:8000 &
kubectl port-forward deployment/dev-tasklist 8003:8000 &

minikube tunnel
