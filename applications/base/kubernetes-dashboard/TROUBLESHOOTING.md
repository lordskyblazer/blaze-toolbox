# Troubleshooting Dashboard CrashLoopBackOff

## 🔍 Step 1: Check the Error

Run these commands to see what's actually wrong:

```bash
# Get pod name
POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l app=kubernetes-dashboard -o jsonpath='{.items[0].metadata.name}')

# Check pod status
kubectl get pod $POD_NAME -n kubernetes-dashboard

# Describe pod (shows events and errors)
kubectl describe pod $POD_NAME -n kubernetes-dashboard

# Check logs (most important!)
kubectl logs $POD_NAME -n kubernetes-dashboard --tail=100

# Check recent events
kubectl get events -n kubernetes-dashboard --sort-by='.lastTimestamp' | tail -20
```

## 🐛 Common Issues

### Issue 1: Port Configuration Error
**Symptoms**: "bind: address already in use" or "port not found"
**Solution**: The deployment has been updated to use port 8443 (HTTPS) or 9090 (HTTP)

### Issue 2: Security Context Too Restrictive
**Symptoms**: "Permission denied" or filesystem errors
**Solution**: Removed `readOnlyRootFilesystem: true` and added tmp volume

### Issue 3: Resource Limits Too Low
**Symptoms**: OOMKilled or container exits immediately
**Solution**: Increased memory limits to 512Mi

### Issue 4: Image Pull Issues
**Symptoms**: ImagePullBackOff
**Solution**: 
```bash
# Check if image can be pulled
docker pull kubernetesui/dashboard:v2.7.0

# If that fails, try a different version
# Update deployment.yaml: image: kubernetesui/dashboard:v2.6.1
```

## 🔧 Quick Fix Steps

1. **Delete the current deployment:**
   ```bash
   kubectl delete -k applications/base/kubernetes-dashboard/
   ```

2. **Wait a few seconds:**
   ```bash
   sleep 5
   ```

3. **Re-apply with fixed configuration:**
   ```bash
   kubectl apply -k applications/base/kubernetes-dashboard/
   ```

4. **Watch the pod:**
   ```bash
   kubectl get pods -n kubernetes-dashboard -w
   ```

5. **If still failing, check logs:**
   ```bash
   kubectl logs -n kubernetes-dashboard -l app=kubernetes-dashboard --tail=50
   ```

## 🔄 Alternative: Use Simpler Configuration

If the HTTPS version still doesn't work, you can try the HTTP version:

1. **Backup current deployment:**
   ```bash
   cp applications/base/kubernetes-dashboard/deployment.yaml applications/base/kubernetes-dashboard/deployment.yaml.backup
   ```

2. **Use the simpler HTTP version:**
   ```bash
   # Edit deployment.yaml and change:
   # - containerPort: 8443 → 9090
   # - scheme: HTTPS → HTTP
   # - port: 8443 → 9090
   # - Remove secure-port args, use insecure-port=9090
   ```

3. **Update service.yaml:**
   ```bash
   # Change targetPort: 8443 → 9090
   # Change port: 443 → 80
   ```

## 📋 What Was Fixed

The updated deployment includes:
- ✅ Correct port (8443 for HTTPS)
- ✅ Relaxed security context (removed readOnlyRootFilesystem)
- ✅ Added tmp volume for temporary files
- ✅ Increased memory limits (256Mi → 512Mi)
- ✅ Correct probe configurations

## 🆘 Still Not Working?

Share the output of:
```bash
kubectl logs -n kubernetes-dashboard -l app=kubernetes-dashboard --tail=100
kubectl describe pod -n kubernetes-dashboard -l app=kubernetes-dashboard
```

This will help identify the exact issue!
