# PostgreSQL with Persistent Storage (PVC)

Postgres running in the cluster with **1Gi of disk** claimed via a PersistentVolumeClaim. Data survives pod restarts.

## What’s included

- **PV** (PersistentVolume): for local dev, uses node disk (`hostPath`). In the cloud you’d rely on a StorageClass instead.
- **PVC** (PersistentVolumeClaim): requests 1Gi, binds to the PV (or to a cloud volume in production).
- **Postgres 15** (Alpine): single replica, data on the PVC.
- **Init SQL**: on first run, creates tables for simple use cases (see below).

## Deploy

```bash
kubectl apply -k applications/base/postgres/
```

Check that the PVC is bound and the pod is running:

```bash
kubectl get pvc
kubectl get pods -l app=postgres
```

## Connection from your PC

Port-forward and connect with any Postgres client (psql, DBeaver, etc.):

```bash
kubectl port-forward service/postgres 5432:5432
```

Then:

- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `appdb`
- **User:** `app`
- **Password:** `changeme_local_only` (change in `secret.yaml` for anything beyond local dev)

Example with `psql`:

```bash
PGPASSWORD=changeme_local_only psql -h localhost -p 5432 -U app -d appdb -c "\dt"
```

## Connection from another pod (e.g. Next.js)

From inside the cluster, use the Service:

- **Host:** `postgres` (or `postgres.default.svc.cluster.local`)
- **Port:** `5432`
- **Database:** `appdb`
- **User / Password:** from the secret (or inject via env in your app).

Connection string example (from another deployment in `default`):

```
postgresql://app:changeme_local_only@postgres:5432/appdb
```

## Brainstorm: what to store (simple relational data)

The init script creates two tables you can use as a starting point.

### 1. Page check-ins (“what time did someone check our page?”)

**Table:** `page_checks`

| Column      | Use |
|------------|-----|
| `checked_at` | When they hit the page |
| `page_path`  | e.g. `/`, `/about` |
| `visitor_id` | Session or anonymous id |
| `user_id`    | Optional, if you have auth |
| `metadata`   | Optional JSON (e.g. user-agent, referrer) |

**Idea:** From your Next.js (or any app) backend, on each page load (or on a “check-in” API call), insert a row. Then you can query “who visited when” or “how many hits per page per day”.

Example insert (from your app):

```sql
INSERT INTO page_checks (page_path, visitor_id)
VALUES ('/', 'sess_abc123');
```

### 2. Audit log (who did what, when)

**Table:** `audit_log`

| Column    | Use |
|----------|-----|
| `at`     | When |
| `actor`  | Who (user id or “system”) |
| `action` | e.g. `view_page`, `login`, `update_setting` |
| `resource` | e.g. `/api/settings` |
| `details`   | Optional JSON |

Use this for simple audit trails (e.g. “user X updated profile at time Y”).

### Other ideas

- **Sessions:** Store session id, user id, created_at, expires_at.
- **User preferences:** user_id, key, value (or a small JSON column).
- **Simple analytics:** event name, timestamp, user/session, optional JSON.

All of this is “simple relational” and fits well in Postgres with a small PVC.

## Where the disk actually is

- **Local (Docker Desktop):** The PV uses `hostPath: /data/postgres` on the **node** (the Linux VM Docker uses). So the 1Gi is claimed from that VM’s disk, not from a specific Windows drive. Resetting or removing the cluster can remove that data.
- **Cloud:** Replace the static PV with a StorageClass; the cloud will provision a real disk (e.g. EBS, Azure Disk) and the same PVC and deployment will work.

## Security note

The default password is for **local use only**. For any shared or production environment, change it in `secret.yaml` (and use proper secrets management).
