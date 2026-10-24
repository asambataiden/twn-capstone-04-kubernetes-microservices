# CAP04-005 — Portfolio Evidence and Acceptance Matrix

**Recorded:** 24 October 2026  
**Evidence type:** User-operated terminal/browser results documented throughout CAP04-002–004. No assertions of automated tests not run.  
**Target application:** Online Boutique v0.8.0.

## Environment boundaries

| Environment | Cluster/namespace | Role |
|---|---|---|
| Local learning lab | `k3d-twn-capstone04` / `online-boutique` | Pinned-release deployment and troubleshooting, Apple Silicon ARM64 |
| Existing AWS EKS | `floral-mongoose-1792497995`, `eu-north-1` / `online-shop` | Independently observed existing AMD64 deployment; application acceptance and disposable operations demonstrations |

**Important:** These are **different** installations. EKS was already running; successful EKS tests do not demonstrate that the capstone deployment script successfully deployed the same stack to EKS.

## Acceptance results

| ID | Criterion | Observed evidence | Assessment |
|---|---|---|---|
| A01 | Retrieve pinned application release | `scripts/capstone04-deploy.sh fetch`, source commit `218ba3d...` | PASS, local lab |
| A02 | Kubernetes server-side manifest validation | 24 release resources accepted by `plan` dry-run | PASS, local lab |
| A03 | Local release installation | All 24 resource definitions applied to k3d | PASS for submission of resources only |
| A04 | Local app functional checkout | Cartservice crashed under ARM64/AMD64 image mismatch; frontend HTTP 500 | **FAIL**, documented, not masked |
| A05 | Existing EKS node compatibility | Both workers Ready `amd64` | PASS, observed |
| A06 | Existing EKS workload availability | 11 Deployments available; 11 Pods Running 1/1, zero restarts | PASS, point-in-time |
| A07 | EKS storefront HTTP | Local port-forward `127.0.0.1:18081` returned HTTP 200 | PASS |
| A08 | Product browsing and details | Operator manually confirmed both | PASS, manual |
| A09 | Cart and simulated checkout | Operator manually confirmed both | PASS, manual; no real charges |
| A10 | EKS service image audit | Detected `adservice` had shippingservice image | DEFECT DISCOVERED |
| A11 | EKS adservice correction | Changed only Deployment/adservice to adservice:v0.8.0; revision 2 1/1 Ready; logs show listening on 9555 and receiving gRPC ad requests | PASS for running service |
| A12 | EKS ad display | gRPC request logs observed; browser ad rendering not independently evidenced | PARTIAL |
| A13 | Controller self-healing | Deleted disposable `cap04-self-healing-demo` Pod, new Ready Pod recreated | PASS |
| A14 | Rolling update | Disposable `cap04-rolling-update-demo` image `pause:3.10` → `pause:3.9`; revision 2 Ready | PASS |
| A15 | Rollback | `kubectl rollout undo` restored `pause:3.10`; revision 3 Ready | PASS |
| A16 | Demo cleanup | Both disposable test Deployments deleted | PASS |
| A17 | EKS reproducibility | Original applied manifest provenance unknown; old incorrect last-applied Adservice image persists | **OPEN** |
| A18 | Upstream parity | Existing EKS has 11 Deployments without upstream loadgenerator; access exposure also differs | **INTENTIONAL/UNRESOLVED DRIFT**, no equivalence claim |
| A19 | Official TWN rubric | No official rubric / completed instructor submission evidence available | NOT VERIFIED |

## Validation commands (read-only)

```bash
# Prints pinned context, worker architecture, workload images, status, frontend Services.
bash scripts/capstone04-eks-evidence.sh

CTX='aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io'
NS='online-shop'
kubectl --context "$CTX" -n "$NS" get deployments,pods
kubectl --context "$CTX" -n "$NS" get deployment adservice \
  -o 'jsonpath={.spec.template.spec.containers[0].image}{"\n"}'
kubectl --context "$CTX" -n "$NS" apply view-last-applied deployment/adservice -o yaml
```

Avoid pasting public LoadBalancer addresses or private configuration into portfolio evidence unnecessarily. Treat runtime observations as time-bound; later execution can produce different results.

## Evidence sources inside this repository

- [Deployment/incident narrative](deployment.md): pinned release, k3d resources, cartservice incident, EKS checks, image defect discovery/correction and application request logs.
- [Self-healing experiment](operations-self-healing.md): original and replacement Pod observations and demo cleanup.
- [Rolling update experiment](operations-rolling-update.md): image version transition, revision history, rollback and demo cleanup.
- [Lessons and open follow-up](lessons-learned.md): implications, trade-offs and remaining closure gates.

## Milestone / PR traceability

| Milestone | Outcome |
|---|---|
| CAP04-001 — Architecture and scope | Merged into `main` |
| CAP04-002 — Kubernetes environment baseline | Merged into `main` |
| [CAP04-003 — Deployment and validation](https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/pull/3) | Merged with limitations explicitly documented |
| [CAP04-004 — Kubernetes operations](https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/pull/4) | Merged; both disposable operational tests complete |
| CAP04-005 — Portfolio closeout | Documentation review in progress |

## What is not claimed

- A high-availability, zero-downtime or multi-replica production application.
- Full Kubernetes security hardening, encrypted public ingress, authenticated Redis or persistent cart storage.
- Exact upstream release deployment equivalence on EKS.
- Ansible/Terraform/GitOps/CI-CD work outside the bootcamp capstone scope.
- Official TWN certification or acceptance.
