# Next.js Demo Application

A simple demo application for learning Kubernetes deployments.

## What This Does

This is a basic web server that displays a landing page. It's designed as a learning example to understand:
- Kubernetes Deployments
- Services
- ConfigMaps
- Kustomize

## Files

- `deployment.yaml` - Defines the pod replicas and container image
- `service.yaml` - Exposes the deployment internally in the cluster
- `configmap.yaml` - Contains the HTML content for the landing page
- `kustomization.yaml` - Kustomize configuration to tie everything together

## Deploy

```bash
kubectl apply -k applications/base/nextjs-demo/
```

## Access

### Option 1: Port Forward (for local testing)
```bash
kubectl port-forward service/nextjs-demo 8080:80
# Visit http://localhost:8080
```

### Option 2: Ingress (if configured)
Once you set up ingress, you can access via the ingress URL.

## Check Status

```bash
# Check pods
kubectl get pods -l app=nextjs-demo

# Check service
kubectl get service nextjs-demo

# View logs
kubectl logs -l app=nextjs-demo
```

## Next Steps

When you're ready to deploy a real Next.js app:

1. Build your Next.js app into a Docker image
2. Push it to a container registry (Docker Hub, GitHub Container Registry, etc.)
3. Update `deployment.yaml` to use your image:
   ```yaml
   image: your-registry/your-nextjs-app:tag
   ```
4. Update the port if your Next.js app uses a different port (default is 3000)
5. Update `service.yaml` to match the port

## Clean Up

```bash
kubectl delete -k applications/base/nextjs-demo/
```
