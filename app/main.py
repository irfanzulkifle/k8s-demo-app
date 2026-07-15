"""Minimal FastAPI service for the k8s-demo-app portfolio project.

Demonstrates a production-minded layout: health and metrics endpoints for
orchestrator probes and observability, plus one business endpoint.
"""
from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI(title="k8s-demo-app", version="1.0.0")


@app.get("/")
def root():
    return {"service": "k8s-demo-app", "status": "ok", "version": "1.0.0"}


@app.get("/health")
def health():
    """Liveness/readiness probe target. Returns 200 when the process is up."""
    return {"status": "healthy"}


@app.get("/metrics")
def metrics():
    """Tiny Prometheus-style metrics endpoint (no client lib dependency)."""
    return JSONResponse(
        content={
            "requests_total": 1,
            "service": "k8s-demo-app",
        },
        headers={"Content-Type": "text/plain; version=0.0.4"},
    )


@app.get("/info")
def info():
    """Reads configuration injected via ConfigMap/Secret to show K8s wiring."""
    import os

    return {
        "environment": os.environ.get("APP_ENV", "unknown"),
        "region": os.environ.get("APP_REGION", "unknown"),
        "has_api_token": bool(os.environ.get("API_TOKEN")),
    }
