#!/bin/bash

helm repo add camunda https://helm.camunda.io
DOCKER_BUILDKIT=0 docker build -t keycloak-arm:latest "https://github.com/camunda/camunda-platform.git#main:.keycloak/"
./pull_camunda.sh
./spinup.sh