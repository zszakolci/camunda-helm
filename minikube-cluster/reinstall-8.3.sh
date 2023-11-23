#!/bin/bash

minikube profile c8.3
helm uninstall dev
kubectx c8.3
kubectl delete namespace camunda
kubectl delete pvc --all

#kubectl delete --ignore-not-found=true -f kube-prometheus-main/manifests/ -f kube-prometheus-main/manifests/setup

docker exec c8.3 rm -rf /tmp/hostpath-provisioner/camunda
#docker exec minikube sh -c 'chmod -R 777 /tmp/hostpath-provisioner/default' 
#minikube addons enable ingress
kubectl create namespace camunda
#kubectl create namespace monitoring
kubens camunda
kubectl apply -n camunda -f ./secret.yaml
#kubectl apply -n monitoring -f ./secret.yaml
#kubectl apply --server-side -f kube-prometheus-main/manifests/setup
#kubectl wait \
#	--for condition=Established \
#	--all CustomResourceDefinition \
#	--namespace=monitoring
# kubectl apply -f kube-prometheus-main/manifests/
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
helm template dev camunda/camunda-platform --namespace camunda --values values/separate-ingress-values-8.3.yaml > templates/camunda-8.3.1.yaml
#kubectl apply -n camunda -f templates/camunda-8.3.1.yaml
#sleep 3
#kubectl delete $(kubectl get pods --no-headers -o name |  awk '{if ($1 ~ "dev-(.+)-test") print $0}')
 helm install dev camunda/camunda-platform --namespace camunda -f values/separate-ingress-values-8.3.yaml
sleep 60

kubectl create -n camunda -f kibana-8.3.yaml
kubectl apply -n camunda -f kibana-ingress.yaml

kubectl port-forward deployment/dev-zeebe-gateway 8000:8000 &
kubectl port-forward statefulset/dev-zeebe 8001:8000 &
kubectl port-forward deployment/dev-operate 8002:8000 &
kubectl port-forward deployment/dev-tasklist 8003:8000 &

minikube tunnel
