#!/bin/bash

DOCKER_BUILDKIT=0 docker build -t keycloak-arm "https://github.com/camunda/camunda-platform.git#main:.keycloak/"
./pull_camunda.sh
./spinup.sh