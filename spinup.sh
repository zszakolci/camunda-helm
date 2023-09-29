#!/bin/bash

minikube delete --all
rm -rf $HOME/.minikube
sleep 15

minikube start --kubernetes-version=v1.26.0 --bootstrapper=kubeadm --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=Webhook --extra-config=scheduler.bind-address=0.0.0.0 --extra-config=controller-manager.bind-address=0.0.0.0 --memory=13.5G --cpus max

kubectl create secret docker-registry dev-c8-registry \
                                      --docker-server=https://registry.camunda.cloud/ \
                                      --docker-username=zalan.szakolci \
                                      --docker-password='fE7MFZEjYrRY56tG' \
                                      --docker-email=zalan.szakolci@camunda.com

kubectl apply -f ./secret.yaml

kubectl apply --server-side -f kube-prometheus-main/manifests/setup
kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
kubectl apply -f kube-prometheus-main/manifests/

sleep 10
minikube addons enable ingress

minikube image load camunda/operate:8.2.15
minikube image load camunda/identity:8.2.15
minikube image load camunda/optimize:3.10.5
minikube image load camunda/tasklist:8.2.15
minikube image load camunda/zeebe:8.2.15
minikube image load camunda/connectors-bundle:0.21.4
minikube image load keycloak-arm
minikube image load docker.elastic.co/elasticsearch/elasticsearch:7.17.10
minikube image load registry.camunda.cloud/web-modeler-ee/modeler-webapp:8.2.6
minikube image load registry.camunda.cloud/web-modeler-ee/modeler-restapi:8.2.6
minikube image load registry.camunda.cloud/web-modeler-ee/modeler-websockets:8.2.6
minikube image load bitnami/postgresql:15.3.0
minikube image load kibana:7.17.10

helm repo update
helm install dev camunda/camunda-platform -f separate-ingress-values.yaml

sleep 120
kubectl create -f kibana.yaml
kubectl apply -f kibana-ingress.yaml
kubectl apply -f grafana-ingress.yaml
# kubectl port-forward svc/dev-identity 8080:80 &
# kubectl port-forward svc/dev-operate  8081:80 &
# kubectl port-forward svc/dev-tasklist 8082:80 &
# kubectl port-forward svc/dev-optimize 8083:80 &
# kubectl port-forward svc/dev-connectors 8088:8080 &
# kubectl port-forward svc/dev-web-modeler-webapp 8084:80 &
# kubectl port-forward svc/dev-web-modeler-websockets 8085:80 &
# kubectl port-forward svc/dev-zeebe-gateway 26500:26500 -n default &
# kubectl port-forward svc/dev-keycloak 18080:80 &   

minikube tunnel 