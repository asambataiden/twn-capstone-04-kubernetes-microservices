# CAP04 — Shell Script Reference and Operator Runbook

**Project:** TechWorld with Nana (TWN) DevOps Bootcamp — Capstone 04  
**Verified against:** scripts on `main` as of 24 October 2026  
**Audience:** DevOps learners and reviewers operating the local lab or inspecting the existing EKS deployment  
**Scope:** Three tracked Bash scripts; two supporting Kubernetes manifests. This is a description of the **implemented commands**, not a proposal to add automation.

> **Critical separation:** The local k3d cluster (`k3d-twn-capstone04` / `online-boutique`) and the already-existing AWS EKS cluster (`floral-mongoose-1792497995` / `online-shop`) are independent. The local deploy script **cannot deploy to EKS**; the EKS evidence script **does not deploy anything**.

## 1. Script responsibility map

| Script | Milestone | Target | Responsibility | Mutating commands |
|---|---|---|---|---|
| [`capstone04-cluster.sh`](../scripts/capstone04-cluster.sh) | CAP04-002 | Local k3d only | Create, inspect and remove isolated Kubernetes lab | `create`, `namespace`, `destroy` |
| [`capstone04-deploy.sh`](../scripts/capstone04-deploy.sh) | CAP04-003 | Local k3d only | Fetch fixed upstream release, server-validate and optionally apply Online Boutique | `deploy` |
| [`capstone04-eks-evidence.sh`](../scripts/capstone04-eks-evidence.sh) | CAP04-003 evidence | Existing AWS EKS only | Verify expected cluster, report nodes, Deployment images, Pod status and frontend exposure | **None** |

All three scripts use `#!/usr/bin/env bash` and `set -Eeuo pipefail`, which causes most command failures, unset-variable references and pipeline errors to terminate the script rather than silently continuing. None of the scripts changes the shell's global Kubernetes context.

### Command risk classification

| Script command | Expected persistent cluster change | Interactive confirmation |
|---|---|---|
| Cluster `preflight`, `verify`, `status` | None | No |
| Cluster `create` | Creates local cluster if absent | No; **explicit command itself authorizes creation** |
| Cluster `namespace` | Creates namespace if absent | No |
| Cluster `destroy` | Deletes **entire local cluster** | Yes: `DELETE twn-capstone04` |
| Deploy `fetch` | None; temporary download removed at process exit | No |
| Deploy `plan` | No persisted application objects (server dry-run) | No |
| Deploy `deploy` | Creates or updates upstream application objects in local namespace | Yes: `DEPLOY k3d-twn-capstone04/online-boutique` |
| Deploy `status` | None | No |
| EKS evidence script | None; `aws eks describe-cluster` + `kubectl get` only | No |

**Server-side dry-run nuance:** `kubectl apply --dry-run=server` exercises Kubernetes API validation/admission and intends no persistent object changes. It does **not** prove container runtime health, image architecture compatibility, or sufficient resource capacity.

## 2. Prerequisites and environment identity

Run all commands at the root of the `twn-capstone-04-kubernetes-microservices` Git working tree, where `scripts/` is present. `bash scripts/...` works from interactive macOS Zsh; executable file permissions are not required because Bash is invoked explicitly.

| Tool / requirement | Needed for | Check |
|---|---|---|
| `bash` | All scripts | `bash --version` (macOS's Bash is sufficient for current syntax) |
| Docker Engine / Docker Desktop | k3d cluster `preflight` and `create` | `docker info` |
| `k3d` | Local cluster commands and deploy `plan/deploy/status` | `k3d version` |
| `kubectl` | All Kubernetes interactions | `kubectl version --client` |
| `curl` | Deployment manifest download | `curl --version` |
| `aws` CLI configured to describe intended EKS cluster | EKS evidence | `aws --version` |
| Correct kubeconfig contexts and permissions | Local and EKS connectivity | `kubectl config get-contexts -o name` |

### Hard-coded targets

**Local k3d:**
- Cluster: `twn-capstone04`
- Kubernetes context: `k3d-twn-capstone04`
- Namespace: `online-boutique`

**Existing EKS (read-only inventory):**
- Region: `eu-north-1`
- Cluster: `floral-mongoose-1792497995`
- Context: `aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io`
- Namespace: `online-shop`

Do not replace hard-coded context strings casually: they are intentional protection against accidentally targeting a different local cluster or another AWS workload.

## 3. `capstone04-cluster.sh` — Local cluster lifecycle

**Use case:** Set up a repeatable, isolated local learning environment before applying application manifests. This script manages the local k3d Kubernetes runtime, **not** application releases.

### Commands

#### `preflight` — Dependency and runtime inspection

```bash
bash scripts/capstone04-cluster.sh preflight
```

- **Prerequisites:** Docker, k3d, kubectl installed; Docker Engine running.
- **Actual behavior:** Checks executables, calls `docker info`, reports Docker/k3d/kubectl versions, prints the current kubectl context **for information**, lists k3d clusters.
- **Expected evidence:** Lines beginning `[cap04]` and a k3d cluster listing; no cluster created.
- **Failure handling:** Start Docker Desktop if engine unavailable; install/fix missing CLI tools. Do not interpret a currently selected unrelated kube context as the target—the script does not adopt it.

#### `create` — Idempotent local cluster creation

```bash
bash scripts/capstone04-cluster.sh create
```

- **Prerequisites:** Successful preflight; enough local CPU, memory and disk.
- **Actual behavior:** Creates `twn-capstone04` with one k3d server and zero extra agents (`--servers 1 --agents 0 --wait`) **only if absent**. Then runs `verify`.
- **Expected evidence:** Creation output or `already exists; no modification`, cluster info, nodes and `kube-system` Pods.
- **Failure handling:** Check Docker capacity and `k3d cluster list`; if cluster creation partially fails, inspect state before attempting deletion or recreation. This command does not provision AWS EKS.
- **Idempotence:** Existing named cluster is not recreated.

#### `verify` — Control plane and system Pod health

```bash
bash scripts/capstone04-cluster.sh verify
```

- **Prerequisites:** Dedicated cluster and `k3d-twn-capstone04` context present.
- **Actual behavior:** Executes `cluster-info`, `get nodes -o wide`, and `get pods -n kube-system` against the explicit local context.
- **Expected evidence:** API server reachable, local node listed and system Pod states visible.
- **Failure handling:** Confirm expected k3d cluster exists and kubectl context matches; inspect system Pods if unhealthy.

#### `namespace` — Idempotent application namespace setup

```bash
bash scripts/capstone04-cluster.sh namespace
```

- **Prerequisites:** k3d cluster exists; API reachable.
- **Actual behavior:** Checks for `online-boutique`, creates it only when missing, then prints namespace details.
- **Expected evidence:** Namespace shown in `kubectl get namespace`.
- **Failure handling:** Check cluster connectivity and namespace permissions. Do not use a broad `kubectl create namespace` without selecting the expected context.

#### `status` — Local state inventory

```bash
bash scripts/capstone04-cluster.sh status
```

- **Prerequisites:** Dedicated k3d cluster exists.
- **Actual behavior:** Lists nodes; if `online-boutique` exists, lists Deployments, Pods and Services. Otherwise prints that the namespace is absent.
- **Expected evidence:** Kubernetes resource table; may legitimately contain no workloads before deployment.
- **Failure handling:** Verify context and namespace. An empty namespace is not itself an error.

#### `destroy` — Destructive lab teardown

```bash
bash scripts/capstone04-cluster.sh destroy
```

- **Prerequisites:** Interactive terminal; understand that all resources and nonpersistent data in this **dedicated local k3d cluster** will be lost.
- **Actual behavior:** If cluster exists, asks for the exact phrase `DELETE twn-capstone04`; deletes the named local cluster only after confirmation.
- **Expected evidence:** `Dedicated cluster removed`; no EKS modifications.
- **Failure handling:** If no cluster exists, exits successfully with `absent; nothing to delete`. If interrupted, check `k3d cluster list` before retrying. **Do not run this to troubleshoot unrelated Kubernetes contexts.**

### Recommended local initialization sequence

```bash
bash scripts/capstone04-cluster.sh preflight
bash scripts/capstone04-cluster.sh create
bash scripts/capstone04-cluster.sh namespace
bash scripts/capstone04-cluster.sh verify
bash scripts/capstone04-cluster.sh status
```

## 4. `capstone04-deploy.sh` — Guarded application release

**Use case:** Retrieve one immutable-source-revision release manifest and deploy its predefined resources to the isolated local lab. The script **does not** provision Kubernetes infrastructure.

**Release provenance:**
- Source repo: `asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo`
- Commit: `218ba3dcef1d19821711e62996162f8b29c55be4`
- File: `release/kubernetes-manifests.yaml`
- The recorded release contains 24 resources (12 Deployments and 12 Services, including a loadgenerator).
- The script pins a Git SHA and checks identifying text in the downloaded file. **It does not verify an independent cryptographic content checksum or image digests.** Image tags used by the release are therefore not immutable by themselves.

### `fetch` — Source acquisition and sanity checks

```bash
bash scripts/capstone04-deploy.sh fetch
```

- **Prerequisites:** curl and Internet access to the pinned raw GitHub artifact. A local cluster is **not** required.
- **Actual behavior:** Downloads the YAML to a `mktemp` path with HTTP failure handling and retries; rejects empty files, missing generated-manifest warning marker, and missing expected Google sample image references. Logs the pinned source SHA, then deletes the temporary file through a trap.
- **Expected evidence:** `Pinned upstream source: ...` and `Downloaded and checked pinned source (temporary artifact automatically removed)`.
- **Important distinction:** Despite the script's usage text saying it prints the URL, the implementation prints the **source SHA**, not the literal download URL. The URL is defined in the script.
- **Failure handling:** Verify network/DNS, GitHub availability, source SHA and file path; do not work around validation by downloading an unpinned latest manifest.

### `plan` — Kubernetes API manifest validation

```bash
bash scripts/capstone04-deploy.sh plan
```

- **Prerequisites:** All local cluster initialization steps completed; curl, kubectl and k3d available; target namespace exists.
- **Actual behavior:** Fetches fresh temporary pinned YAML, confirms exact k3d cluster/context/namespace, calls `kubectl apply --dry-run=server --validate=strict`.
- **Expected evidence:** Kubernetes API reports `created (server dry run)` or similar for each object, followed by `Dry-run completed; no application resources created`.
- **Failure handling:** Resolve missing cluster/context/namespace, permissions, API schema or malformed manifest. A passing `plan` does **not** show available Pods or verify that the container images can execute.

### `deploy` — Apply release, explicitly confirmed

```bash
bash scripts/capstone04-deploy.sh deploy
```

- **Prerequisites:** Completed `plan`, adequate resources and reviewed release image compatibility; **real interactive terminal**.
- **Actual behavior:** Downloads and validates the manifest again, asks for **exactly** `DEPLOY k3d-twn-capstone04/online-boutique`, then uses `kubectl apply --validate=strict` against the explicit local context/namespace. Finally lists Deployments, Pods and Services.
- **Expected evidence:** API `created`, `configured`, or `unchanged` messages and a current state inventory.
- **Change scope:** It may create **or update** resources included in the upstream manifest. Repeating `kubectl apply` does not guarantee zero changes if cluster objects differ. It is neither Helm nor GitOps.
- **Failure handling:** Stop after errors; inspect Pod events, image/platform support, resources and logs; do not repeatedly apply or disable probes to hide failures. The script has **no built-in rollback, retrying rollout wait, or teardown**.
- **Known lab outcome:** On an ARM64 k3d node, upstream `cartservice:v0.8.0` was only available as AMD64, and the observed .NET cart workload crashed; local checkout did **not** pass. Preserve this as incident evidence, not deployment success.

### `status` — Read-only resource inventory

```bash
bash scripts/capstone04-deploy.sh status
```

- **Prerequisites:** Local cluster/context and `online-boutique` namespace reachable.
- **Actual behavior:** Lists Deployments, Pods and Services.
- **Expected evidence:** Current readiness and resource states. These are momentary observations, not an end-to-end acceptance test.
- **Failure handling:** Verify local cluster API and permissions first.

### Safe diagnostics after `deploy`

```bash
kubectl --context k3d-twn-capstone04 -n online-boutique get deployments,pods,services
kubectl --context k3d-twn-capstone04 -n online-boutique get events --sort-by=.lastTimestamp
kubectl --context k3d-twn-capstone04 -n online-boutique describe deployment/cartservice
kubectl --context k3d-twn-capstone04 -n online-boutique logs deployment/cartservice --tail=100
```

Inspect architecture compatibility with an independent image-manifest tool as needed; do not assume that an accepted Kubernetes manifest can execute on your machine.

### Recovery and rollback boundaries

- There is **no** `deploy.sh rollback` or `deploy.sh delete` command.
- If the local application is broken, retain logs and events, identify the specific faulty Deployment and decide whether a narrowly scoped, version-controlled correction is appropriate.
- For complete lab disposal, use `cluster.sh destroy` **only after reviewing the loss of all data and resources** in that dedicated cluster.
- Do not run this script against `online-shop` on EKS, or manually redirect the full 24-resource upstream manifest there.

## 5. `capstone04-eks-evidence.sh` — Existing EKS read-only inspection

**Use case:** Validate identity and inspect the **pre-existing** EKS Online Boutique installation, without changing application state.

```bash
bash scripts/capstone04-eks-evidence.sh
```

### Prerequisites

- AWS CLI authenticated with permission for `eks:DescribeCluster` on the intended cluster.
- Local kubectl/kubeconfig containing the exact expected EKS context and working Kubernetes API read permissions.
- Network access to AWS EKS metadata API and the EKS control plane.
- Existing `online-shop` namespace, `frontend` and `frontend-external` Services.

### Identity protection and read-only sequence

1. Verify `aws` and `kubectl` executables exist.
2. Ask AWS EKS for exact named cluster status and require `ACTIVE`.
3. Retrieve the intended cluster's current API endpoint from AWS.
4. Resolve the hard-coded kubectl context's cluster and API server.
5. **Reject** the operation if the context endpoint differs from AWS's endpoint.
6. Check that the target Kubernetes namespace is accessible.
7. Print node names, a selected `READY` field and CPU architectures.
8. Print Deployment names, available-replica counts and container images.
9. Print Pod health/restarts and frontend Service types and endpoints.
10. Report completion without mutating workloads.

### Expected evidence

Previous operator output showed two AMD64 EKS workers, 11 available Online Boutique Deployments, and 11 Running Pods with zero restarts at the observation time. The output revealed `adservice` was initially using a shippingservice image. The operator corrected **only** that live Deployment in a separate, explicitly approved terminal operation; the script itself did **not** perform the correction.

**Script limitations:**
- The printed node `READY` column currently reads `.status.conditions[-1].type`, which is not a robust general-purpose readiness check; use `kubectl --context "$CTX" get nodes` and inspect the Ready condition when readiness matters.
- This is an inventory, not a functional test, architecture scanner, source-of-truth diff, audit log, or saved evidence artifact.
- No images are pushed, Pods restarted, objects applied or resources deleted.
- The Kubernetes Service listing can expose existing public LoadBalancer DNS names; review copied output before publishing it.

### Failure handling

| Message / symptom | Meaning | Recommended operator response |
|---|---|---|
| `Missing executable: aws` or `kubectl` | Required CLI absent from PATH | Install/configure the correct CLI |
| `Could not describe intended EKS cluster` | AWS identity, region, permissions or connectivity issue | Check AWS authentication and `eks:DescribeCluster` access |
| `EKS cluster is not ACTIVE` | Intended cluster is not currently active | Stop and investigate cluster status; do not switch to a different cluster automatically |
| `Kubeconfig context missing` | Expected context absent | Check `kubectl config get-contexts -o name`; configure the intended cluster deliberately |
| `Context server does not match` | Current kubeconfig server differs from live named EKS endpoint | **Stop** and verify the EKS configuration; never bypass the guard |
| `Existing namespace not accessible` | Namespace missing or access denied | Verify namespace existence and RBAC; do not create it as part of evidence collection |
| `frontend-external` not found | Expected Service differs from environment | Record deviation; do not provision a new public LoadBalancer just for this script |

### Read-only supplementary checks (manual; not implemented in script)

```bash
CTX='aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io'
NS='online-shop'

kubectl --context "$CTX" -n "$NS" get deployment adservice \
  -o 'jsonpath={.spec.template.spec.containers[0].image}{"\n"}'
kubectl --context "$CTX" -n "$NS" apply view-last-applied deployment/adservice -o yaml
kubectl --context "$CTX" -n "$NS" logs deployment/adservice --tail=50
```

**Recorded gap:** Live `adservice` was corrected to `adservice:v0.8.0`, but the **last-applied configuration still contained `shippingservice:v0.8.0`**. The original authoritative EKS manifest has not been identified. The evidence script does not reconcile that drift. Never claim full EKS declarative reproducibility until provenance is resolved.

## 6. Supporting manifests: CAP04-004 operations

These are **declarative Kubernetes YAML files**, not executable shell scripts:

| File | Purpose | Verified result |
|---|---|---|
| [`manifests/operations/self-healing-demo.yaml`](../manifests/operations/self-healing-demo.yaml) | Create one disposable `pause:3.10` Deployment; intentionally delete only its test Pod and observe automatic ReplicaSet replacement | Replacement Pod Ready; test Deployment cleaned up |
| [`manifests/operations/rolling-update-demo.yaml`](../manifests/operations/rolling-update-demo.yaml) | Create one disposable pause Deployment; update image to `pause:3.9`, inspect revisions and rollback to `pause:3.10` | Update and rollback successful; test Deployment cleaned up |

Both use minimal resource requests/limits, non-root execution, disabled automatic service-account token mount, dropped Linux capabilities and RuntimeDefault seccomp. Neither creates a public Service.

For **exact** test commands and destructive-operation boundaries, use:
- [Self-healing procedure](operations-self-healing.md)
- [Rolling update and rollback procedure](operations-rolling-update.md)

Do not use real Online Boutique Pods for these destructive learning exercises. The existing storefront is a single-replica application.

## 7. End-to-end operator workflows

### Workflow A — New local learning lab

```bash
bash scripts/capstone04-cluster.sh preflight
bash scripts/capstone04-cluster.sh create
bash scripts/capstone04-cluster.sh namespace
bash scripts/capstone04-cluster.sh verify
bash scripts/capstone04-deploy.sh fetch
bash scripts/capstone04-deploy.sh plan
# Only if deliberately recreating the local exercise and image/platform caveat is understood:
bash scripts/capstone04-deploy.sh deploy
bash scripts/capstone04-deploy.sh status
```

**Stop before `deploy`** if the ARM64 cartservice compatibility issue remains unresolved and the objective is a fully working local shopping journey.

### Workflow B — Existing EKS status check (no modifications)

```bash
bash scripts/capstone04-eks-evidence.sh
```

Use this when collecting operational evidence or verifying image inventories. It never creates infrastructure and makes no EKS deployment claims.

### Workflow C — Local lab cleanup (optional, destructive)

```bash
bash scripts/capstone04-cluster.sh status
# Confirm no local evidence/data needs to be preserved:
bash scripts/capstone04-cluster.sh destroy
```

The command deletes the local cluster, including its Deployments, Services and namespace. It does **not** delete AWS EKS or its pre-existing Online Boutique workload.

## 8. Learning objectives and professional engineering practices

| Engineering principle | Implementation | Remaining limitation |
|---|---|---|
| Separation of concerns | Distinct cluster, deploy and evidence scripts | No universal multi-environment deployment interface (by design) |
| Context safety | Explicit hard-coded Kubernetes context/namespace | Not a replacement for Kubernetes RBAC |
| Idempotence | Cluster/namespace existence checks; Kubernetes `apply` | Applying upstream manifests may intentionally reconcile live changes |
| Reproducibility | Pinned upstream Git commit | Image tags are not pinned digests; full EKS provenance unresolved |
| Validation | Dependency checks; Kubernetes strict server dry-run | Admission success does not establish runtime health |
| Change safety | Exact confirmations for local deploy and local cluster deletion | Creation and namespace mutation do not request separate confirmation |
| Least privilege | EKS evidence only reads; disposable manifests use restricted container settings | Operator credentials still require appropriate permission design |
| Operational observability | Workload/image/Pod inventory; documented diagnostics | No continuous monitoring, automated E2E validation or historical metrics |
| Recoverability | Targeted diagnosis; reversible CAP04-004 test examples | No application deployment rollback script |
| Documentation | This command runbook plus CAP04 deployment/operations evidence | Official TWN assessment checklist remains unverified |

## 9. Troubleshooting quick reference

| Problem | First check | Avoid |
|---|---|---|
| `command not found` | Tool installed and present in `PATH` | Blind upgrades of unrelated tooling |
| Docker engine unavailable | `docker info` and Docker Desktop | Recreating unrelated clusters |
| k3d context missing | `k3d cluster list`, `kubectl config get-contexts -o name` | Applying manifests to `kubectl`'s implicit default context |
| Namespace missing | `cluster.sh namespace` for **local k3d only** | Creating namespaces on EKS during evidence collection |
| Manifest plan fails | Correct pinned release / API versions / permissions | Bypassing `--validate=strict` |
| Pod `CrashLoopBackOff` | `kubectl describe pod`, prior logs, image architecture and node resources | Assuming Ready at one instant means healthy |
| Local frontend port already used | `lsof -nP -iTCP:18080 -sTCP:LISTEN`; choose another unused local port | Terminating unrelated processes |
| EKS API mismatch | Confirm exact named cluster and kubeconfig endpoint | Removing the EKS identity guard |
| `adservice` image drift | Live Pod template vs last-applied configuration and authoritative Git manifest | Blindly reapplying full upstream release into EKS |
| Paid public endpoint persists | Review cloud LoadBalancer ownership and cost separately | Deleting existing services solely to tidy portfolio output |

## 10. Final boundaries

This repository documents **real operator-observed** local cluster deployment, an ARM64 cartservice incident, existing EKS service validation, and two disposable Kubernetes operations tests. It does **not** demonstrate production-grade HA, durable Redis data, complete EKS infrastructure provisioning, or official TWN assessment completion.

For observed results, see [portfolio evidence](portfolio-evidence.md); for the outstanding EKS source-of-truth risk, see [lessons learned](lessons-learned.md).
