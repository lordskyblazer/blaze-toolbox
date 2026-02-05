#!/bin/bash
# Dashboard Diagnostic Script

echo "=== Kubernetes Dashboard Diagnostic ==="
echo ""

echo "1. Checking pod status..."
kubectl get pods -n kubernetes-dashboard
echo ""

echo "2. Getting pod name..."
POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l app=kubernetes-dashboard -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -z "$POD_NAME" ]; then
    echo "   No pod found!"
    exit 1
fi
echo "   Pod: $POD_NAME"
echo ""

echo "3. Pod status details..."
kubectl get pod $POD_NAME -n kubernetes-dashboard -o wide
echo ""

echo "4. Pod events (most recent)..."
kubectl describe pod $POD_NAME -n kubernetes-dashboard | grep -A 20 "Events:"
echo ""

echo "5. Container logs (last 50 lines)..."
kubectl logs $POD_NAME -n kubernetes-dashboard --tail=50
echo ""

echo "6. Previous container logs (if restarted)..."
kubectl logs $POD_NAME -n kubernetes-dashboard --tail=50 --previous 2>/dev/null || echo "   No previous logs"
echo ""

echo "7. Recent namespace events..."
kubectl get events -n kubernetes-dashboard --sort-by='.lastTimestamp' | tail -10
echo ""

echo "=== Diagnostic Complete ==="
