# Application Structure Guide

This document explains how to organize applications in this Kubernetes cluster repository.

## 📁 Directory Structure

```
applications/
├── base/                    # Base configurations (common across environments)
│   ├── nextjs-demo/        # Example: Next.js demo app
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── kustomization.yaml
│   ├── go-api/             # Example: Go API service
│   └── python-worker/      # Example: Python background worker
│
└── staging/                 # Staging environment overlays
    ├── nextjs-demo/        # Staging-specific configs for Next.js
    │   └── kustomization.yaml  # Overlays base with staging values
    └── go-api/
        └── kustomization.yaml
```

## 🎯 Organization Principles

### 1. **Base Directory (`applications/base/`)**
- Contains **base configurations** that are common across all environments
- Each application gets its own subdirectory
- Includes: Deployment, Service, ConfigMap, etc.
- Always includes a `kustomization.yaml` for Kustomize

### 2. **Environment Overlays (`applications/<env>/`)**
- Contains **environment-specific** configurations
- Uses Kustomize overlays to modify base configs
- Examples: `staging/`, `production/`, `development/`
- Typically only contains `kustomization.yaml` that references base

### 3. **Naming Conventions**
- Use **kebab-case** for directory names: `nextjs-demo`, `go-api`, `python-worker`
- Keep names descriptive and technology-agnostic when possible
- Match the `app` label in your Kubernetes resources

## 📝 Creating a New Application

### Step 1: Create Base Configuration

```bash
mkdir -p applications/base/my-app
cd applications/base/my-app
```

### Step 2: Create Kubernetes Manifests

Create your deployment, service, and other resources:

- `deployment.yaml` - Your application deployment
- `service.yaml` - Service to expose your app
- `configmap.yaml` - Configuration data (optional)
- `kustomization.yaml` - Kustomize configuration (required)

### Step 3: Create Kustomization File

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  # Add other resources here

commonLabels:
  app: my-app
  managed-by: kustomize
```

### Step 4: Deploy

```bash
# Deploy base configuration
kubectl apply -k applications/base/my-app/

# Or deploy with environment overlay
kubectl apply -k applications/staging/my-app/
```

## 🔄 Environment-Specific Configurations

### Example: Staging Overlay

Create `applications/staging/my-app/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: staging

resources:
  - ../../base/my-app

replicas:
  - name: my-app
    count: 3

patches:
  - target:
      kind: Deployment
      name: my-app
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/image
        value: my-registry.io/my-app:staging-v1.0.0
```

## 🎨 Multi-Technology Support

This structure supports applications written in any language/framework:

- **Web Apps**: Next.js, React, Vue, Angular
- **APIs**: Go, Node.js, Python (FastAPI/Flask), Java (Spring Boot)
- **Workers**: Python, Go, Node.js background jobs
- **Databases**: PostgreSQL, MongoDB, Redis (if needed in apps/)
- **Tools**: Monitoring, logging, utilities

Each technology gets its own directory under `applications/base/`.

## 📚 Examples

### Next.js Application
See: `applications/base/nextjs-demo/`

### Go API Service
```
applications/base/go-api/
├── deployment.yaml
├── service.yaml
└── kustomization.yaml
```

### Python Worker
```
applications/base/python-worker/
├── deployment.yaml
├── configmap.yaml
└── kustomization.yaml
```

## 🚀 Quick Reference

| Task | Command |
|------|---------|
| Deploy base app | `kubectl apply -k applications/base/<app-name>/` |
| Deploy with overlay | `kubectl apply -k applications/<env>/<app-name>/` |
| Preview changes | `kubectl kustomize applications/base/<app-name>/` |
| Delete app | `kubectl delete -k applications/base/<app-name>/` |

## 💡 Best Practices

1. **Always use Kustomize** - It's built into kubectl and makes management easier
2. **Keep base configs generic** - Environment-specific values go in overlays
3. **Use labels consistently** - Helps with service discovery and monitoring
4. **Document your apps** - Add a README.md in each app directory if needed
5. **Version your images** - Use specific tags, not `latest`
6. **Resource limits** - Always set requests and limits for containers
