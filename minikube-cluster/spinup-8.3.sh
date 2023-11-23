#!/bin/bash
minikube delete --profile c8.3
sleep 15

minikube start --kubernetes-version=v1.28.3 --namespace camunda --profile c8.3 --bootstrapper=kubeadm --driver docker --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=Webhook --extra-config=scheduler.bind-address=0.0.0.0 --extra-config=controller-manager.bind-address=0.0.0.0 --memory max --cpus max
kubectx c8.3
minikube profile c8.3

# minikube addons disable storage-provisioner
# minikube addons disable default-storageclass
# minikube addons enable volumesnapshots
# minikube addons enable csi-hostpath-driver
# kubectl patch storageclass csi-hostpath-sc -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl create namespace camunda
kubens camunda

kubectl create namespace monitoring

kubectl create -n camunda secret docker-registry dev-c8-registry \
                                      --docker-server=https://registry.camunda.cloud/ \
                                      --docker-username=user \
                                      --docker-password='passw' \
                                      --docker-email=email

kubectl apply -n camunda -f ./secret.yaml
kubectl apply -n monitoring -f ./secret.yaml
kubectl apply --server-side -f kube-prometheus-main/manifests/setup
kubectl wait \
    --for condition=Established \
    --all CustomResourceDefinition \
    --namespace=monitoring
 kubectl apply -f kube-prometheus-main/manifests/

sleep 10
minikube addons enable ingress
# minikube addons enable ingress-dns
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
 # minikube image load camunda/operate:8.3.1
 # minikube image load camunda/identity:8.3.1
 # minikube image load camunda/optimize:3.11.1
 # minikube image load camunda/tasklist:8.3.1
 # minikube image load camunda/zeebe:8.3.1
 # minikube image load camunda/connectors-bundle:8.3.0
 # minikube image load bitnami/keycloak:22.0.4
 # minikube image load docker.elastic.co/elasticsearch/elasticsearch:8.8.2
 # minikube image load registry.camunda.cloud/web-modeler-ee/modeler-webapp:8.3.0
 # minikube image load registry.camunda.cloud/web-modeler-ee/modeler-restapi:8.3.0
 # minikube image load registry.camunda.cloud/web-modeler-ee/modeler-websockets:8.3.0
 # minikube image load bitnami/postgresql:15.4.0
 # minikube image load kibana:8.8.2

helm repo update
helm install dev camunda/camunda-platform --namespace camunda -f values/separate-ingress-values-8.3.yaml
helm template dev camunda/camunda-platform -n camunda --values values/separate-ingress-values-8.3.yaml > templates/camunda-8.3.1.yaml
#kubectl apply -n camunda -f templates/camunda-8.3.1.yaml
#kubectl delete $(kubectl get pods --no-headers -o name |  awk '{if ($1 ~ "dev-(.+)-test") print $0}')
sleep 60
kubectl create -n camunda -f kibana-8.3.yaml
kubectl apply -n camunda -f kibana-ingress.yaml

kubectl port-forward deployment/dev-zeebe-gateway 8000:8000 &
kubectl port-forward statefulset/dev-zeebe 8001:8000 &
kubectl port-forward deployment/dev-operate 8002:8000 &
kubectl port-forward deployment/dev-tasklist 8003:8000 &
minikube tunnel