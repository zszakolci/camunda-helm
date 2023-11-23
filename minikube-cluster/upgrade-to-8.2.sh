#!/bin/bash

minikube profile c8.2
helm upgrade -f separate-ingress-values-8.2.yaml --version 8.2 dev camunda/camunda-platform
minikube tunnel
