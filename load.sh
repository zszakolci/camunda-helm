# kind  load docker-image camunda/operate:8.2.10
# kind  load docker-image camunda/identity:8.2.10
# kind  load docker-image camunda/optimize:3.10.2
# kind  load docker-image camunda/tasklist:8.2.10
# kind  load docker-image camunda/zeebe:8.2.10

kind load docker-image camunda/connectors-bundle:0.21.3
kind load docker-image keycloak-arm
kind load docker-image docker.elastic.co/elasticsearch/elasticsearch:7.17.10
kind load docker-image registry.camunda.cloud/web-modeler-ee/modeler-webapp:8.2.4
kind load docker-image registry.camunda.cloud/web-modeler-ee/modeler-restapi:8.2.4
kind load docker-image registry.camunda.cloud/web-modeler-ee/modeler-websockets:8.2.4
kind load docker-image bitnami/postgresql:15.3.0