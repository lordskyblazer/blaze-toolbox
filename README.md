# Kubernetes Cluster Configuration

Cross-platform Kubernetes cluster configuration for web applications (Go, Next.js).

## 🏗️ Architecture

This repository follows GitOps principles and is organized for:
- Development environment (local/on-prem)
- Future production deployment
- Multi-platform compatibility (Windows/Linux)

## 📁 Repository Structure

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
kubectl apply -k applications/base/web-app/
