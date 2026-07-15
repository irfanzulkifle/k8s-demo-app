# Architecture

This repo demonstrates a containerized service deployed to Kubernetes through
Infrastructure-as-Code and a CI/CD pipeline.

## Flow

```
git push to main
      |
      v
GitHub Actions
  - build image (docker buildx)
  - Trivy scan (fail on CRITICAL/HIGH)
  - push to GHCR
  - kubectl apply manifests
      |
      v
Kind cluster (local) / EKS (cloud)
  - Deployment (2 replicas, probes, limits)
  - Service (ClusterIP)
  - ConfigMap + Secret
  - HPA (CPU 70%)
```

## Local run

```
kind create cluster --name k8s-demo-local   # or: terraform apply (terraform/)
kubectl apply -f k8s/
kubectl port-forward svc/k8s-demo-app 8080:80
curl localhost:8080/health
```

## Why these choices

- Multi-stage Dockerfile + non-root user: small attack surface, no root in container.
- Kind for local: free, runs on the VPS, same manifests as EKS.
- Trivy in CI: vulnerable images never reach a registry.
- OIDC permission block: ready for cloud deploy with no static keys.
