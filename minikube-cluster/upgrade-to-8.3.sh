#!/bin/bash

minikube profile c8.3
helm upgrade -f separate-ingress-values-8.3.yaml dev camunda/camunda-platform
minikube tunnel
