#!/bin/bash

helm uninstall dev
kubectl delete pvc --all

# minikube image load camunda/operate:8.2.10
# minikube image load camunda/identity:8.2.10
# minikube image load camunda/optimize:3.10.2
# minikube image load camunda/tasklist:8.2.10
# minikube image load camunda/zeebe:8.2.10

helm repo update
helm install dev camunda/camunda-platform -f c8-no-ingress-no-tls-no-modeller-values.yaml
sleep 60

kubectl port-forward svc/dev-identity 8080:80 &
kubectl port-forward svc/dev-operate  8081:80 &
kubectl port-forward svc/dev-tasklist 8082:80 &
kubectl port-forward svc/dev-optimize 8083:80 &
kubectl port-forward svc/dev-connectors 8088:8080 &
kubectl port-forward svc/dev-web-modeler-webapp 8084:80 &
kubectl port-forward svc/dev-web-modeler-websockets 8085:80 &
kubectl port-forward svc/dev-zeebe-gateway 26500:26500 -n default &
kubectl port-forward svc/dev-keycloak 18080:80 &   