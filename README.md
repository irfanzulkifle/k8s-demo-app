# k8s-demo-app

A containerized FastAPI service deployed to Kubernetes with Infrastructure-as-Code
and a CI/CD pipeline. Built to demonstrate the full path from code to a running,
scanned, auto-scaled service.

## What it shows

- **Docker**: multi-stage build, non-root runtime user, healthcheck
- **Kubernetes**: Deployment, Service, ConfigMap, Secret, HPA with probes and resource limits
- **Terraform**: provisions a local Kind cluster (swap the provider for EKS to go cloud)
- **CI/CD**: GitHub Actions builds, scans with Trivy, pushes to GHCR and deploys
- **Security**: image vulnerability gate, no hardcoded secrets, OIDC-ready for cloud

## Run locally

```bash
# 1. Cluster
terraform -chdir=terraform init && terraform -chdir=terraform apply
# (or) kind create cluster --name k8s-demo-local

# 2. Deploy
kubectl apply -f k8s/
kubectl rollout status deployment/k8s-demo-app

# 3. Try it
kubectl port-forward svc/k8s-demo-app 8080:80
curl localhost:8080/health
```

## Run the app without Kubernetes

```bash
pip install -r app/requirements.txt
uvicorn app.main:app --port 8000
```

## Test

```bash
pip install -r app/requirements.txt && pip install "fastapi[test]"
cd app && python -m pytest tests/
```

## Endpoints

| Path | Purpose |
|------|---------|
| `/` | Service info |
| `/health` | Liveness/readiness probe |
| `/metrics` | Prometheus-style metrics |
| `/info` | Shows ConfigMap/Secret injection |

## Tech stack

| Layer | Tool |
|-------|------|
| Runtime | Python 3.12, FastAPI |
| Container | Docker (multi-stage, slim) |
| Orchestration | Kubernetes (Kind locally, EKS-ready) |
| IaC | Terraform (kind provider) |
| CI/CD | GitHub Actions, GHCR |
| Scanning | Trivy |

