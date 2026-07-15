# k8s-demo-app

A containerized FastAPI service deployed to Kubernetes with Infrastructure-as-Code
and a CI/CD pipeline. Built to demonstrate the full path from code to a running,
scanned, auto-scaled service.

## What it shows

- **Docker**: multi-stage build, non-root runtime user, healthcheck
- **Kubernetes**: Deployment, Service, ConfigMap, Secret, HPA with probes and resource limits
- **Terraform**: provisions a local Kind cluster (swap the provider for EKS to go cloud)
- **CI/CD**: GitHub Actions builds the image, scans it with Trivy (fails on CRITICAL/HIGH), then deploys when a cluster is configured
- **Security**: image vulnerability gate (Trivy), no hardcoded secrets, OIDC-ready for cloud

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
| CI/CD | GitHub Actions (build, Trivy scan, conditional deploy) |
| Scanning | Trivy (CRITICAL/HIGH gate) |

## CI/CD

The `build-scan-deploy` workflow runs on every push to `main`:

1. **Build** the Docker image with Buildx.
2. **Scan** with Trivy. The build fails on any CRITICAL or HIGH vulnerability
   (with `ignore-unfixed: true` so only fixable issues block the gate).
3. **Deploy** (only on `main`, and only if a `KUBE_CONFIG` secret is set in
   repo settings). Without the secret the deploy step is skipped and the
   pipeline stays green — set the secret to a base64-encoded kubeconfig to
   enable real deploys to your cluster.

To enable deploys, add a repository secret `KUBE_CONFIG` containing the
base64-encoded output of `cat ~/.kube/config` from your cluster.