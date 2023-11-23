#!/bin/bash

kubectx kind-camunda-platform-8.2
kubens camunda
helm repo update
helm upgrade -f camunda-platform/separate-ingress-values-8.2.yaml --version 8.2.18 dev camunda/camunda-platform
