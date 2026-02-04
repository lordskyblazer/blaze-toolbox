# Local Development Guide

This guide covers managing resources, shutting down services, and best practices for local Kubernetes development with Docker Desktop.

## 🖥️ Resource Management

### Docker Desktop Settings

Docker Desktop can consume significant resources. Configure it appropriately:

1. **Open Docker Desktop Settings** (gear icon)
2. **Resources Tab**:
   - **CPUs**: Allocate 2-4 cores (depending on your system)
   - **Memory**: 
     - Minimum: 4GB for basic testing
     - Recommended: 8GB for comfortable development
     - Maximum: Don't exceed 50% of your total RAM
   - **Disk**: 20-40GB should be sufficient for images and containers
   - **Swap**: 1-2GB (helps prevent OOM kills)

3. **Kubernetes Tab**:
   - Enable Kubernetes if not already enabled
   - Consider disabling if you're not actively using it to save resources

### Monitoring Resource Usage

```bash
# Check Docker resource usage
docker stats

# Check Kubernetes pod resource usage
kubectl top pods

# Check node resources
kubectl top nodes

# View all resources in a namespace
kubectl get all
```

### Managing Application Resources

Your deployments already have resource limits set. To adjust them:

**Edit `deployment.yaml`:**
```yaml
resources:
  requests:
    memory: "128Mi"    # Minimum guaranteed
    cpu: "100m"        # 0.1 CPU cores
  limits:
    memory: "256Mi"    # Maximum allowed
    cpu: "200m"        # 0.2 CPU cores
```

**For local development, you can reduce resources:**
- Simple web apps: 64-128Mi memory, 50-100m CPU
- APIs: 128-256Mi memory, 100-200m CPU
- Databases: 512Mi-1Gi memory, 500m-1 CPU

### Reducing Replicas for Local Development

For local testing, you often don't need multiple replicas:

```yaml
spec:
  replicas: 1  # Instead of 2 or more
```

Or scale down existing deployments:
```bash
kubectl scale deployment nextjs-demo --replicas=1
```

## 🛑 Shutting Down Services

### Quick Shutdown (Recommended)

```bash
# Delete your application
kubectl delete -k applications/base/nextjs-demo/

# Or delete all resources in default namespace (be careful!)
kubectl delete all --all -n default
```

### Graceful Shutdown

Kubernetes handles graceful shutdowns automatically:
- Pods receive SIGTERM signal
- Containers have 30 seconds (default) to finish
- Then SIGKILL if still running

### Stop Docker Desktop

1. **Right-click Docker Desktop icon** in system tray
2. **Quit Docker Desktop**
   - This stops all containers and the Kubernetes cluster
   - All resources are released

### Complete Cleanup

If you want to completely reset:

```bash
# Delete all resources
kubectl delete all --all --all-namespaces

# Reset Kubernetes cluster in Docker Desktop
# Settings > Kubernetes > Reset Kubernetes Cluster
```

## 🔄 Daily Workflow

### Starting Your Day

```bash
# 1. Start Docker Desktop (if not running)

# 2. Verify cluster is running
kubectl cluster-info

# 3. Deploy your applications
kubectl apply -k applications/base/nextjs-demo/

# 4. Check status
kubectl get pods
```

### During Development

```bash
# Watch pods in real-time
kubectl get pods -w

# View logs
kubectl logs -f deployment/nextjs-demo

# Restart a deployment (useful after config changes)
kubectl rollout restart deployment/nextjs-demo
```

### Ending Your Day

```bash
# Option 1: Delete specific apps (recommended)
kubectl delete -k applications/base/nextjs-demo/

# Option 2: Scale down to 0 (keeps config, stops pods)
kubectl scale deployment nextjs-demo --replicas=0

# Option 3: Stop Docker Desktop (stops everything)
```

## 💾 Disk Space Management

Docker can accumulate images and containers over time:

```bash
# Check disk usage
docker system df

# Clean up unused resources
docker system prune

# Remove all unused images, containers, networks
docker system prune -a

# Remove unused volumes (be careful!)
docker volume prune
```

**Docker Desktop**: Settings > Resources > Advanced > Clean / Purge data

## 🔍 Troubleshooting

### High CPU/Memory Usage

```bash
# Find resource-hungry pods
kubectl top pods --sort-by=memory
kubectl top pods --sort-by=cpu

# Check specific pod
kubectl describe pod <pod-name>

# View events
kubectl get events --sort-by='.lastTimestamp'
```

### Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe pod for details
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Check if resources are available
kubectl describe nodes
```

### Port Already in Use

```bash
# Find what's using a port (Windows)
netstat -ano | findstr :8080

# Kill process (replace PID with actual process ID)
taskkill /PID <PID> /F

# Or use a different port for port-forward
kubectl port-forward service/nextjs-demo 8081:80
```

## 📝 Best Practices

### 1. **Use Namespaces for Organization**

```bash
# Create a namespace for your apps
kubectl create namespace development

# Deploy to namespace
kubectl apply -k applications/base/nextjs-demo/ -n development
```

### 2. **Clean Up Regularly**

- Delete unused deployments when done testing
- Run `docker system prune` weekly
- Remove old images you're not using

### 3. **Monitor Resource Usage**

- Check `docker stats` periodically
- Use `kubectl top` to see actual usage
- Adjust resource limits based on real usage

### 4. **Use Resource Limits**

Always set resource requests and limits in your deployments (already done in your configs!)

### 5. **Scale Down When Not Using**

```bash
# Scale to 0 when not actively developing
kubectl scale deployment nextjs-demo --replicas=0

# Scale back up when needed
kubectl scale deployment nextjs-demo --replicas=2
```

### 6. **Stop Port Forwards**

Port forwards keep running even after closing terminal. Stop them:
- Press `Ctrl+C` in the terminal running port-forward
- Or find and kill the process using the port

## 🚨 Important Notes

1. **Docker Desktop uses resources even when idle** - Consider quitting when not in use
2. **Kubernetes cluster runs continuously** - Stop it if you're not actively developing
3. **Images take up space** - Clean up unused images regularly
4. **Port forwards persist** - Make sure to stop them when done
5. **Resource limits prevent runaway processes** - Always set them!

## 📚 Useful Commands Cheat Sheet

```bash
# Resource Management
kubectl top pods                    # Pod resource usage
kubectl top nodes                   # Node resource usage
docker stats                        # Container stats

# Scaling
kubectl scale deployment <name> --replicas=0    # Stop
kubectl scale deployment <name> --replicas=1    # Start

# Cleanup
kubectl delete -k <path>           # Delete app
kubectl delete all --all           # Delete all in namespace
docker system prune                 # Clean Docker

# Monitoring
kubectl get pods -w                # Watch pods
kubectl logs -f <pod>              # Follow logs
kubectl describe pod <pod>         # Pod details
```

## 🔗 Next Steps

- Set up resource monitoring alerts (optional)
- Create development vs production resource profiles
- Learn about Horizontal Pod Autoscaling (HPA) for production
- Explore namespace-based resource quotas
