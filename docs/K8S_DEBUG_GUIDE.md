# Kubernetes Local Development Troubleshooting

## 1. Secrets & Authentication
* **Passwords**: If `FATAL: password authentication failed` occurs, Postgres likely initialized with an old password. 
* **The "First Boot" Rule**: Postgres only sets the password when the data directory is empty. Changing a Secret does NOT update a running database.
* **Fix**: Change the `hostPath` in `pv.yaml` or delete the local data folder to force re-initialization.

## 2. Persistent Storage (Local)
* **PV Status**: If a PVC is `Pending`, check `kubectl get pv`. If the status is `Released`, the PV is locked to a deleted claim.
* **Unlock PV**: Use `kubectl patch pv <name> -p '{\"spec\":{\"claimRef\":null}}'` (Note: escape quotes in PowerShell).

## 3. Networking & Init
* **InitContainers**: Always use a `wait-for-postgres` init container in the app Deployment to prevent the app from crashing while the database is still warming up.
* **Service Selectors**: If `port-forward` fails with "no selector," ensure the Service `spec.selector` matches the Deployment `spec.template.metadata.labels`.

## 4. Useful Commands
* **Test Postgres**: `kubectl exec -it deployment/postgres -- psql -U postgres`
* **Check Env Vars**: `kubectl exec <pod-name> -- env | Select-String "KEY"`
* **Check Endpoints**: `kubectl get endpoints <service-name>`
