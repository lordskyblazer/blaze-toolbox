# Kubernetes Dashboard Diagnostic Script (PowerShell)

Write-Host "=== Kubernetes Dashboard Diagnostic ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Checking pod status..." -ForegroundColor Yellow
kubectl get pods -n kubernetes-dashboard
Write-Host ""

Write-Host "2. Getting pod details..." -ForegroundColor Yellow
$podName = kubectl get pods -n kubernetes-dashboard -l app=kubernetes-dashboard -o jsonpath='{.items[0].metadata.name}' 2>$null
if ($podName) {
    Write-Host "   Pod: $podName" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "3. Pod status details..." -ForegroundColor Yellow
    kubectl get pod $podName -n kubernetes-dashboard -o wide
    Write-Host ""
    
    Write-Host "4. Pod events (most recent)..." -ForegroundColor Yellow
    kubectl describe pod $podName -n kubernetes-dashboard
    Write-Host ""
    
    Write-Host "5. Container logs (last 100 lines)..." -ForegroundColor Yellow
    kubectl logs $podName -n kubernetes-dashboard --tail=100
    Write-Host ""
    
    Write-Host "6. Previous container logs (if restarted)..." -ForegroundColor Yellow
    kubectl logs $podName -n kubernetes-dashboard --tail=100 --previous 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   No previous logs" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host "   No pod found!" -ForegroundColor Red
}

Write-Host "7. Recent namespace events..." -ForegroundColor Yellow
kubectl get events -n kubernetes-dashboard --sort-by='.lastTimestamp' | Select-Object -Last 10
Write-Host ""

Write-Host "8. Checking service account..." -ForegroundColor Yellow
kubectl get serviceaccount -n kubernetes-dashboard
Write-Host ""

Write-Host "9. Checking RBAC..." -ForegroundColor Yellow
kubectl get clusterrolebinding kubernetes-dashboard-admin
Write-Host ""

Write-Host "=== Diagnostic Complete ===" -ForegroundColor Cyan
