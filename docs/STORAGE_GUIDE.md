# Kubernetes Storage Guide

How your PC stores data under Kubernetes, how to see it, and how it changes when you move to the cloud.

---

## How your setup stores data today

### Where things actually live

| What | Where it lives | Survives pod restart? |
|------|----------------|------------------------|
| **Your project files** (this repo) | **Windows disk** – e.g. `E:\home\work\2026\tlb\blaze-toolbox` | Yes (normal files) |
| **Container images** (nginx, dashboard) | **Docker Desktop VM** – inside the Linux VM Docker uses | Yes (until you prune) |
| **nextjs-demo HTML** | **ConfigMap** → mounted read-only into the pod | Yes (in cluster state) |
| **Dashboard /tmp** | **emptyDir** – temporary dir on the node (inside Docker VM) | No |
| **Cluster state** (Pods, Services, ConfigMaps, etc.) | **etcd** – inside the Docker Desktop Kubernetes node | Yes (until you reset the cluster) |

So:

- **Your code and YAML** = normal Windows folders and files. You can open them in Explorer, VS Code, etc.
- **What runs inside the cluster** = copies of that (images + ConfigMaps). The cluster does **not** mount your Windows project directory by default.

### Seeing “project files” on Windows

- **On your PC:**  
  Your project is just a normal folder, e.g.  
  `E:\home\work\2026\tlb\blaze-toolbox`  
  You can browse it in File Explorer, open in Cursor/VS Code, etc. Kubernetes does not “own” this folder.

- **Inside the cluster:**  
  - **nextjs-demo:** The HTML is in a **ConfigMap** (`nextjs-demo-html`). It’s stored in etcd and mounted into each pod at `/usr/share/nginx/html`. That’s a *copy* of the content from your YAML, not a live sync of your Windows folder.
  - **Dashboard:** Only uses an **emptyDir** for `/tmp` (logs, temp files). No part of your Windows project is mounted there.

So “see the files of our project” =  
- On Windows: browse the repo folder.  
- In the cluster: the only “project-like” data is the ConfigMap content (and whatever is baked into images).

---

## Local (Docker Desktop) vs cloud – how storage behaves

### On your PC (Docker Desktop)

- **Node** = a Linux VM or process that Docker Desktop manages. You don’t usually SSH into it.
- **Disks** used by the cluster are inside that VM (or Docker’s storage driver). They are **not** the same as your Windows `E:\` or `C:\` unless you explicitly use a **hostPath** volume (see below).
- **emptyDir** = a temporary directory on that node’s filesystem. When the pod is deleted, it’s gone.
- **ConfigMap/Secret** = stored in **etcd** (cluster DB). No separate “disk” in the sense of a drive letter.

So: **“How is my PC storing such data under Kubernetes?”**

- **Cluster state and ConfigMaps:** in the Kubernetes database (etcd) inside Docker’s environment.
- **Container writable layers + emptyDir:** in Docker’s storage (e.g. overlay2) inside the Docker Desktop VM.
- **Your project:** on the Windows filesystem, separate from the cluster. The cluster only sees what you put in images and ConfigMaps.

### When you go to the cloud

- **Nodes** = real VMs or bare metal in a cloud (e.g. AWS, Azure, GCP).
- **Persistent storage** = provided by the cloud (e.g. EBS, Azure Disk, GCE PD). You request it with **PersistentVolumeClaim (PVC)** and the cluster binds it to your pod.
- **emptyDir** still = temporary; **ConfigMaps/Secrets** still = etcd. So behavior is the same in concept; only the “node disk” and “network storage” are different.

So:

- **Now (local):** Data is either in etcd, in the container/emptyDir space inside Docker’s VM, or on your Windows drive (your repo).
- **In cloud:** Same ideas, but “node disk” and “network volumes” are cloud disks; your “project files” would typically come from Git (e.g. CI/CD) or from a volume you attach, not from your laptop’s `E:\`.

---

## Ways to expand: storage ideas for your cluster

### 1. **PersistentVolumeClaim (PVC)** – “a disk that survives”

- Use for: DB data, uploads, anything that must survive pod restart.
- **Local:** On Docker Desktop, a PVC often uses a **hostPath** or local provisioner; the “disk” is a directory on the node (inside the VM).
- **Cloud:** PVC binds to a cloud volume (EBS, Azure Disk, etc.). Same YAML, different backend.

Good next step: add a small example app (e.g. Redis or a tiny API) that uses a PVC so you see how it behaves locally and later in the cloud.

### 2. **hostPath** – “use a folder from the node”

- Use for: dev only, e.g. mounting a path from the node into the pod. On Docker Desktop, the “node” is the VM, so you don’t see your Windows path unless the VM is set up to expose it.
- **Not** recommended for production (tied to one node, security concerns).

### 3. **ConfigMaps / Secrets** – what you already use

- You already use a ConfigMap for nextjs-demo HTML. Good for config and small, non-secret data. For “project files” that you want to edit on Windows and “see” in the cluster, you’d typically:
  - Build an image from your repo and push it, or
  - Use a dev tool (e.g. Skaffold, Tilt) that syncs your Windows folder into the cluster (or rebuilds and redeploys).

### 4. **Cloud-native options (when you’re in the cloud)**

- **Object storage (S3, Azure Blob, GCS):** for files, backups, static assets. Apps use SDKs or gateways (e.g. MinIO) inside the cluster.
- **Managed DBs (RDS, Cosmos, etc.):** data lives outside the cluster; pods connect via connection strings (in Secrets).

---

## Quick reference: “Where is it?”

| You want to… | Where it is / what to use |
|--------------|---------------------------|
| Edit and see **project files on Windows** | Your repo folder, e.g. `E:\home\work\2026\tlb\blaze-toolbox` – open in Explorer / Cursor. |
| See **what the app serves** (e.g. HTML) | ConfigMap `nextjs-demo-html` → mounted in pod; or inspect with `kubectl exec` / Dashboard. |
| Have **data survive pod restart** | Add a **PersistentVolumeClaim** and mount it in the pod. |
| Use **same YAML locally and in cloud** | Use PVC + StorageClass; local provisioner locally, cloud provisioner in cloud. |

---

## Example: PostgreSQL with PVC

The repo includes a working example: **`applications/base/postgres/`**.

- **PV** (local dev): `hostPath` so the PVC can bind on Docker Desktop.
- **PVC**: claims 1Gi; Postgres stores its data there so it survives restarts.
- **Init SQL**: creates tables for simple use cases (e.g. `page_checks` for “when did someone check our page?”, `audit_log` for who did what when).

Deploy: `kubectl apply -k applications/base/postgres/`

See [applications/base/postgres/README.md](../applications/base/postgres/README.md) for connection details and ideas (page check-ins, audit log, sessions, etc.).

---

## Summary

- **Your PC:** Project lives on Windows; Kubernetes runs inside Docker’s environment. Cluster data = etcd + container/emptyDir storage in the VM. No direct “see Windows files in the cluster” unless you add hostPath or a sync tool.
- **Visualizing:** On Windows you already see your project in Explorer; in the cluster you see “files” only as mounted ConfigMaps or as content inside the container (e.g. via `kubectl exec` or Dashboard).
- **Later:** Add PVCs for persistent data; in the cloud, same concepts but with cloud disks. That’s the natural way to expand storage in this cluster.

If you want, next step can be a minimal **PersistentVolumeClaim + Deployment** example in this repo (e.g. under `applications/base/...`) so you can run it locally and compare behavior when you move to the cloud.
