# Kubernetes Dashboard Setup Guide

## 🎯 What You Need to Know

### 1. **It Runs in Its Own Namespace**
- Dashboard runs in `kubernetes-dashboard` namespace (separate from your apps)
- This is a best practice for infrastructure components
- Your apps (like `nextjs-demo`) run in `default` namespace

### 2. **RBAC (Role-Based Access Control)**
- **ServiceAccount**: Identity for the dashboard pod
- **ClusterRole**: Defines what permissions the dashboard has (read-only in our setup)
- **ClusterRoleBinding**: Connects the ServiceAccount to the ClusterRole
- This is more complex than a simple app, but necessary for security

### 3. **Security Considerations**
- **Local Development**: We use skip-login for convenience
- **Production**: Never use skip-login! Use proper authentication
- The dashboard has read permissions to view cluster resources
- For learning, this is fine; for production, restrict further

### 4. **Resource Usage**
- Uses ~128-256MB RAM
- Single replica (sufficient for local dev)
- Stateless (can be restarted without data loss)

### 5. **Access Method**
- Uses port-forward (not exposed publicly)
- Accessible only on your local machine
- Safe for local development

## 🧪 Simple Functionality Test

After deploying, follow these steps to verify everything works:

### Step 1: Deploy Dashboard
```bash
kubectl apply -k applications/base/kubernetes-dashboard/
```

### Step 2: Wait for Pod to be Ready
```bash
kubectl get pods -n kubernetes-dashboard -w
# Press Ctrl+C when you see: kubernetes-dashboard-xxxxx   1/1   Running
```

### Step 3: Start Port Forward
```bash
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8080:80
# Keep this terminal open!
```

### Step 4: Open Dashboard
Open your browser and go to: **http://localhost:8080**

### Step 5: Test Checklist ✅

In the dashboard UI, verify you can:

1. **See Overview Page**
   - Should show cluster overview
   - No errors should appear

2. **View Your Next.js Demo App**
   - Click "Workloads" → "Deployments"
   - Change namespace to "default" (top dropdown)
   - Find `nextjs-demo` deployment
   - ✅ Should see 2 replicas running

3. **View Pods**
   - Click "Workloads" → "Pods"
   - See `nextjs-demo-xxxxx` pods
   - ✅ Should see 2 pods in Running state

4. **View Pod Details**
   - Click on one of the `nextjs-demo` pods
   - ✅ Should see pod details, events, logs

5. **View Logs**
   - In pod details, click "Logs" tab
   - ✅ Should see nginx access logs

6. **View Services**
   - Click "Services" in left menu
   - ✅ Should see `nextjs-demo` service

### Step 6: Quick Command Verification
```bash
# In a new terminal (keep port-forward running)
kubectl get all -n kubernetes-dashboard
# Should show: deployment, service, pod all running
```

## 🎉 Success Criteria

If you can:
- ✅ Access the dashboard at http://localhost:8080
- ✅ See your `nextjs-demo` deployment
- ✅ View pod logs
- ✅ See services

**Then the dashboard is working correctly!** 🎊

## 🔧 Troubleshooting

### Dashboard won't load
```bash
# Check if pod is running
kubectl get pods -n kubernetes-dashboard

# Check logs
kubectl logs -n kubernetes-dashboard deployment/kubernetes-dashboard
```

### Can't see resources
```bash
# Verify RBAC is set up
kubectl get clusterrolebinding kubernetes-dashboard-admin
kubectl get serviceaccount -n kubernetes-dashboard
```

### Port 8080 already in use
```bash
# Use different port
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8081:80
# Then visit http://localhost:8081
```

## 📝 Notes

- Dashboard runs in a **separate namespace** (`kubernetes-dashboard`)
- Your apps run in **default namespace**
- Use the namespace dropdown in dashboard to switch between namespaces
- Port-forward must stay running to access dashboard
