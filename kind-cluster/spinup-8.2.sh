#!/bin/bash

kind delete cluster --name camunda-platform-8.2
kind create cluster --config cluster/kind-cluster-config.yaml --name camunda-platform-8.2
kubectx kind-camunda-platform-8.2
# kubectl delete namespace camunda
# kubectl delete --ignore-not-found=true -f ../kube-prometheus-main/manifests/ -f ../kube-prometheus-main/manifests/setup
kubectl create namespace camunda
kubens camunda
kubectl kustomize --enable-helm ingress-nginx | kubectl apply -f -

kind load docker-image bitnami/keycloak:19.0.3 -n camunda-platform-8.2
kubectl create namespace monitoring
kubectl apply -n camunda -f camunda-platform/secret.yaml
kubectl apply -n monitoring -f camunda-platform/secret.yaml
kubectl create -n camunda secret docker-registry dev-c8-registry \
                                      --docker-server=https://registry.camunda.cloud/ \
                                      --docker-username=user \
                                      --docker-password='passw' \
                                      --docker-email=email

kubectl apply --server-side -f kube-prometheus-main/manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring
kubectl apply -f kube-prometheus-main/manifests/

helm repo update camunda
helm template dev camunda/camunda-platform --version 8.2.17 -n camunda --values camunda-platform/separate-ingress-values-8.2.yaml > templates/camunda-8.2.17.yaml
helm install dev camunda/camunda-platform --version 8.2.17 --namespace camunda -f camunda-platform/separate-ingress-values-8.2.yaml
#kubectl apply -n camunda -f templates/camunda-8.2.16.yaml
#kubectl delete $(kubectl get pods --no-headers -o name |  awk '{if ($1 ~ "dev-(.+)-test") print $0}')

sleep 60
kubectl create -n camunda -f kibana-8.2.yaml
kubectl apply -n camunda -f kibana-ingress.yaml

kubectl port-forward deployment/dev-zeebe-gateway 8000:8000 &
kubectl port-forward statefulset/dev-zeebe 8001:8000 &
kubectl port-forward deployment/dev-operate 8002:8000 &
kubectl port-forward deployment/dev-tasklist 8003:8000 &