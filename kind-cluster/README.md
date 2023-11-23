# Camunda Platform 8 Local
Local setup for Camunda Platform 8 with Ingress and TLS!

This repo aims to reduce the time and effort spent to spin up the Camunda Platform 8 locally by automating the setup
where it should work the same way across operating systems (Linux, MacOS, and Windows).

# Why?

One of the recurring challenges for different teams (e.g., support and dev) was testing a bug fix
or reproducing an issue when the Ingress controllers and TLS are enabled because that involves extra steps
for DNS and certificate configuration (which is the expected way to use the Camunda Platform by our clients).

# How does it work?

The domain `local.distro.ultrawombat.com` and its all sub-domains point to `127.0.0.1`,
and it will work with Kubernetes local cluster that exposes ports `80` and `443` locally (configured via `KinD`).

# Prerequisites

The following tools are required:

- [KinD](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Helm](https://helm.sh/docs/intro/install/)

If you use [asdf](https://asdf-vm.com/), you can install all the tools with the tested version in one shot:

```
asdf install
```

# Deploy

## Kubernetes cluster

Create:
```
kind create cluster --config cluster/kind-cluster-config.yaml
```

Delete:
```
kind delete cluster --name $(awk '/^name:/{print $2}' cluster/kind-cluster-config.yaml)
```

## Ingress controller

Currently supported Ingress controllers are `Nginx` and `Contour`.

Deploy:
```
kubectl kustomize --enable-helm ingress-nginx | kubectl apply -f -
```

## Camunda Platform 8

The Helm values for Camunda Platform 8 could be customized in
[camunda-platform/helm-chart.yaml](camunda-platform/helm-chart.yaml)

Deploy:
```
kubectl kustomize --enable-helm camunda-platform | kubectl apply -f -
```

# Access

- Keycloak: https://local.distro.ultrawombat.com/auth
- Identity: https://local.distro.ultrawombat.com/identity
- Operate: https://local.distro.ultrawombat.com/operate
- Tasklist: https://local.distro.ultrawombat.com/tasklist
- Optimize: https://local.distro.ultrawombat.com/optimize
- Zeebe (gRPC): zeebe.local.distro.ultrawombat.com

# Pitfalls

## Fritz Box

The URls are working as the DNS entry for them resolves to `127.0.0.1`. If the FritzBox serves as DNS server, it will [refuse to resolve an entry to a private IP address](https://en.avm.de/service/knowledge-base/dok/FRITZ-Box-7360-int/663_No-DNS-resolution-of-private-IP-addresses/). This behaviour can be changed by adding exceptions for `local.distro.ultrawombat.com`. Another option would be the selection of an alternative DNS server `1.1.1.1` for your device or [the FritzBox](https://avm.de/service/wissensdatenbank/dok/FRITZ-Box-7530/165_Andere-DNS-Server-in-FRITZ-Box-einrichten).

## General workaround

If none of this could be applied to your setup, you can modify your [hosts file](https://www.howtogeek.com/27350/beginner-geek-how-to-edit-your-hosts-file/) and add `127.0.0.1 local.distro.ultrawombat.com`

# Future plans

- Use one of Camunda's domains like `local.camunda.com` or so, instead of the current one.
- Automate the certificate renewal (it's done manually now).
- Encrypt the domain certificate with Kustomize
  [SopsSecretGenerator](https://github.com/goabout/kustomize-sopssecretgenerator).
- Provide the same setup on GCP to overcome the limited local resources.

# DRI
The Distribution team.
For any questions, please use [#ask-distribution](https://camunda.slack.com/archives/C03UR0V2R2M).
