# Redis Deployment

## Overview
Redis deployment for the demo application cluster.

## Features
- Redis 7 Alpine image
- Persistent configuration via ConfigMap
- Password authentication via Secret
- Health checks (liveness & readiness probes)
- Service exposure within cluster

## Configuration
- Port: 6379
- Authentication: Enabled (see secret.yaml)
- Persistence: Append-only file (AOF)
- Max Memory: 256MB

## Connecting from other pods
Use: `redis-service.default.svc.cluster.local:6379`

## Updating Password
1. Generate new password: `echo -n "newpassword" | base64`
2. Update `secret.yaml` with new base64 value
3. Apply: `kubectl apply -f secret.yaml`
4. Restart pods: `kubectl rollout restart deployment/redis-deployment`

# VERIFY DEPLOYMENT

## Check if pods are running
kubectl get pods -l app=redis

## Check services
kubectl get svc redis-service

## Check logs
kubectl logs deployment/redis-deployment

## Test connection from a temporary pod
kubectl run redis-test --rm -it --image=redis:alpine -- bash

Inside container: redis-cli -h redis-service -a "your-secure-password" ping

## Troubleshooting Tips
Pod won't start: Check logs with kubectl logs deployment/redis-deployment
Connection refused: Verify service exists kubectl get svc redis-service
Authentication failed: Check secret is applied kubectl get secret redis-secret
Memory issues: Adjust resource limits in deployment.yaml
