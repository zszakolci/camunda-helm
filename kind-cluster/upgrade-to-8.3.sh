#!/bin/bash

kubectx kind-camunda-platform-8.3
kubens camunda
helm repo update
helm upgrade -f camunda-platform/separate-ingress-values-8.3.yaml  dev camunda/camunda-platform
