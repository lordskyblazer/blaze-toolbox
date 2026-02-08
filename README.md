# Kubernetes Cluster Configuration

Cross-platform Kubernetes cluster configuration for web applications (Go, Next.js).

## 🏗️ Architecture

This repository follows GitOps principles and is organized for:
- Development environment (local/on-prem)
- Future production deployment
- Multi-platform compatibility (Windows/Linux)

## 📁 Repository Structure

```
applications/
├── base/                    # Base application configurations
│   ├── nextjs-demo/        # Example Next.js application
│   ├── kubernetes-dashboard/ # Kubernetes Dashboard UI
│   └── postgres/           # PostgreSQL with PVC (persistent storage)
└── staging/                 # Staging environment overlays

clusters/              # Cluster-specific configurations
helm-charts/           # Helm chart templates
infrastructure/        # Infrastructure components (ingress, monitoring, etc.)
manifests/             # Shared manifests (RBAC, network policies, etc.)
```

See [docs/APPLICATION_STRUCTURE.md](docs/APPLICATION_STRUCTURE.md) for detailed application organization guidelines.

See [docs/LOCAL_DEVELOPMENT.md](docs/LOCAL_DEVELOPMENT.md) for resource management, shutdown procedures, and local development best practices.

See [docs/STORAGE_GUIDE.md](docs/STORAGE_GUIDE.md) for how storage works locally vs in the cloud and ideas to expand the cluster.

## 🚀 Quick Start

### Prerequisites
- kubectl
- Docker
- k3d or Minikube (for local development)

### Local Development Setup

```bash
# Clone repository
git clone <your-repo-url>
cd kubernetes-cluster

# Setup local cluster (using k3d)
./scripts/setup-local-cluster.sh

# Deploy base infrastructure
kubectl apply -f manifests/namespaces.yml
kubectl apply -k infrastructure/

# Deploy sample application
kubectl apply -k applications/base/nextjs-demo/

# Access the application (after setting up ingress or port-forward)
kubectl port-forward service/nextjs-demo 8080:80
# Then visit http://localhost:8080

# Deploy Kubernetes Dashboard (optional - for cluster visualization)
kubectl apply -k applications/base/kubernetes-dashboard/
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8081:80
# Then visit http://localhost:8081

# When done, clean up
kubectl delete -k applications/base/nextjs-demo/
```

## 📚 Documentation

- [Application Structure Guide](docs/APPLICATION_STRUCTURE.md) - How to organize and structure applications
- [Local Development Guide](docs/LOCAL_DEVELOPMENT.md) - Resource management, shutdown procedures, and best practices
- [Kubernetes Dashboard Guide](docs/KUBERNETES_DASHBOARD.md) - Dashboard setup, access, and testing

## 🛑 Quick Shutdown

```bash
# Delete application
kubectl delete -k applications/base/nextjs-demo/

# Or scale down to 0 (keeps config, stops pods)
kubectl scale deployment nextjs-demo --replicas=0

# Stop Docker Desktop when completely done (releases all resources)

# test update for git credential manager
