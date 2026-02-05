# Kubernetes Dashboard

Web-based UI for Kubernetes cluster management and monitoring.

## 🎯 What This Does

Kubernetes Dashboard provides a web interface to:
- View and manage pods, services, deployments
- Monitor resource usage
- View logs and events
- Execute commands in containers
- Manage cluster resources visually

## ⚠️ Important Security Notes

### For Local Development (Current Setup)
- Uses a ServiceAccount with read-only cluster permissions
- Skip login is enabled for convenience
- **This setup is for local learning only!**

### For Production
- **Never** use skip-login in production
- Use proper authentication (OIDC, token-based)
- Restrict permissions to minimum required
- Consider using network policies to restrict access

## 📁 Files

- `namespace.yaml` - Creates the `kubernetes-dashboard` namespace
- `serviceaccount.yaml` - Service account for the dashboard
- `clusterrole.yaml` - Permissions for the dashboard (read-only)
- `clusterrolebinding.yaml` - Binds service account to role
- `deployment.yaml` - Dashboard deployment
- `service.yaml` - Service to expose the dashboard
- `kustomization.yaml` - Kustomize configuration

## 🚀 Deploy

```bash
kubectl apply -k applications/base/kubernetes-dashboard/
```

Wait for the pod to be ready:
```bash
kubectl get pods -n kubernetes-dashboard -w
```

## 🔐 Access the Dashboard

### Option 1: Port Forward (Recommended for Local)

```bash
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:80
```

Then visit: **http://localhost:8080**

### Option 2: Get Access Token (Alternative)

```bash
# Get the token for the service account
kubectl -n kubernetes-dashboard create token kubernetes-dashboard
```

Use this token to log in to the dashboard.

## 🧪 Testing Functionality

### Simple Test Checklist

1. **Verify Dashboard is Running**
   ```bash
   kubectl get pods -n kubernetes-dashboard
   # Should show: kubernetes-dashboard-xxxxx   1/1   Running
   ```

2. **Access Dashboard via Port Forward**
   ```bash
   kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:80
   ```

3. **In the Dashboard UI, verify you can:**
   - ✅ See the "Overview" page
   - ✅ View "Workloads" → "Deployments" → See your `nextjs-demo` deployment
   - ✅ View "Workloads" → "Pods" → See running pods
   - ✅ View "Services" → See your services
   - ✅ Click on a pod → View its logs
   - ✅ View resource usage (if metrics-server is installed)

4. **Test Resource Visibility**
   - Navigate to "Workloads" → "Deployments"
   - Find `nextjs-demo` in the `default` namespace
   - Click on it to see details, pods, and events

5. **Test Log Viewing**
   - Go to "Workloads" → "Pods"
   - Click on a `nextjs-demo` pod
   - Click "Logs" tab to view container logs

## 🔍 Verify Setup

```bash
# Check all resources
kubectl get all -n kubernetes-dashboard

# Check service account
kubectl get serviceaccount -n kubernetes-dashboard

# Check cluster role binding
kubectl get clusterrolebinding kubernetes-dashboard-admin

# View dashboard logs
kubectl logs -n kubernetes-dashboard deployment/kubernetes-dashboard
```

## 🛑 Clean Up

```bash
kubectl delete -k applications/base/kubernetes-dashboard/
```

## 📊 Resource Usage

- **Memory**: ~128-256MB
- **CPU**: ~100-200m
- **Disk**: Minimal (stateless)

## 🔧 Troubleshooting

### Dashboard Not Loading
```bash
# Check pod status
kubectl get pods -n kubernetes-dashboard

# Check logs
kubectl logs -n kubernetes-dashboard deployment/kubernetes-dashboard

# Check service
kubectl get svc -n kubernetes-dashboard
```

### Can't See Resources
- Verify the ClusterRoleBinding is created: `kubectl get clusterrolebinding kubernetes-dashboard-admin`
- Check service account: `kubectl get sa -n kubernetes-dashboard`

### Port Already in Use
```bash
# Use a different port
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8081:80
```

## 💡 Tips

1. **Bookmark the URL** - http://localhost:8080 (when port-forwarding)
2. **Use Namespace Filter** - Filter by namespace in the dashboard UI
3. **Explore Different Views** - Try "Workloads", "Services", "Config & Storage"
4. **View Events** - Check the "Events" tab for troubleshooting

## 🔗 Learn More

- [Official Kubernetes Dashboard Docs](https://github.com/kubernetes/dashboard)
- [Dashboard Access Control](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md)
