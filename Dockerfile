# ---- build stage ----
FROM python:3.12-slim AS build
WORKDIR /build
COPY app/requirements.txt .
# Create a self-contained virtualenv so console scripts (uvicorn) live on PATH.
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ---- runtime stage ----
FROM python:3.12-slim
WORKDIR /app
# Bring the whole venv across; its bin/ is added to PATH below.
COPY --from=build /opt/venv /opt/venv
COPY app/main.py .
ENV PATH="/opt/venv/bin:$PATH"

# Run as non-root
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://localhost:8000/health').status==200 else 1)"
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
