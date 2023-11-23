#!/bin/bash

minikube delete --profile c8.2
sleep 15

minikube start --namespace camunda --profile c8.2 --driver docker --bootstrapper=kubeadm  --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=Webhook --extra-config=scheduler.bind-address=0.0.0.0 --extra-config=controller-manager.bind-address=0.0.0.0 --memory max --cpus max
minikube profile c8.2
kubectx c8.2
kubectl create namespace camunda
kubens camunda
kubectl create namespace monitoring

kubectl create secret docker-registry dev-c8-registry \
                                      --docker-server=https://registry.camunda.cloud/ \
                                      --docker-username=zalan.szakolci \
                                      --docker-password='fE7MFZEjYrRY56tG' \
                                      --docker-email=zalan.szakolci@camunda.com

kubectl apply -f ./secret.yaml
kubectl apply -n monitoring -f ./secret.yaml
kubectl apply --server-side -f kube-prometheus-main/manifests/setup
kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
 kubectl apply -f kube-prometheus-main/manifests/

sleep 10
minikube addons enable ingress
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
 # minikube image load camunda/operate:8.2.16
 # minikube image load camunda/identity:8.2.16
 # minikube image load camunda/optimize:3.10.6
 # minikube image load camunda/tasklist:8.2.16
 # minikube image load camunda/zeebe:8.2.16
 # minikube image load camunda/connectors-bundle:0.23.2
 minikube image load keycloak-arm:8.2
 # minikube image load docker.elastic.co/elasticsearch/elasticsearch:7.17.10
 # minikube image load registry.camunda.cloud/web-modeler-ee/modeler-webapp:8.2.6
 # minikube image load registry.camunda.cloud/web-modeler-ee/modeler-restapi:8.2.6
 # minikube image load registry.camunda.cloud/web-modeler-ee/modeler-websockets:8.2.6
 # minikube image load bitnami/postgresql:15.3.0
 # minikube image load kibana:7.17.10

helm repo update
helm template dev camunda/camunda-platform --namespace camunda --values values/separate-ingress-values-8.2.yaml > templates/camunda-8.2.17.yaml
helm install dev camunda/camunda-platform --namespace camunda --version 8.2.17 -f values/separate-ingress-values-8.2.yaml

sleep 60
kubectl create -f kibana-8.2.yaml
kubectl apply -f kibana-ingress.yaml

kubectl port-forward deployment/dev-zeebe-gateway 8000:8000 &
kubectl port-forward statefulset/dev-zeebe 8001:8000 &
kubectl port-forward deployment/dev-operate 8002:8000 &
kubectl port-forward deployment/dev-tasklist 8003:8000 &

minikube tunnel 
