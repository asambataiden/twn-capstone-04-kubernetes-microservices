# TWN DevOps Bootcamp — Capstone 04 Submission Report

**Project:** Deploy a Microservices Application in Kubernetes  
**Application:** Online Boutique (reference release v0.8.0)  
**Repository:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices  
**Report date:** 24 October 2026  
**Status:** Engineering portfolio documentation complete; **official TWN assessment/submission requirements not verified**.

## 1. Executive summary

The objective of Capstone 04 was to investigate, deploy, validate and operate an existing microservices application on Kubernetes, with evidence of Kubernetes workload management and basic operational procedures. The project reused Online Boutique rather than rewriting its business services.

The project delivered a version-pinned, context-guarded release deployment workflow for a dedicated local k3d cluster. The upstream release manifest passed Kubernetes API validation and resources were submitted to the local cluster, but its cartservice v0.8.0 image supported AMD64 while the operator's local cluster used ARM64. The observed cartservice failure prevented successful local shopping-flow acceptance. The incident, including observed crashes, was preserved in the project documentation.

The operator then inspected a **pre-existing** AWS EKS installation of Online Boutique using two AMD64 worker nodes in `eu-north-1`. Without reapplying the full release or creating another cluster, the operator verified the application's catalog, product details, shopping cart and simulated checkout. An EKS image audit uncovered `adservice` mistakenly configured with a shippingservice image. A targeted live correction restored `adservice:v0.8.0`; its Pod became healthy, the storefront returned HTTP 200 and its logs showed incoming ad gRPC requests.

Finally, two separately named disposable workloads demonstrated Kubernetes ReplicaSet self-healing and Deployment rolling update/rollback behavior. Both test Deployments were removed afterward. Portfolio documentation distinguishes the observed successes from open provenance and submission questions.

## 2. Architecture and environments

The application follows a frontend-and-backend microservices model. The frontend invokes internal Services for product catalog, recommendations, ads, currency, cart and checkout. Cart state uses Redis; simulated checkout integrates mock payment, shipping and email interactions.

**Test environments are distinct:**

| Environment | Purpose | Observed outcome |
|---|---|---|
| Local k3d, context `k3d-twn-capstone04`, namespace `online-boutique` | Standalone release application and troubleshooting exercise on Apple Silicon ARM64 | Manifest accepted/applied; application checkout failed due to observed cartservice instability |
| Existing AWS EKS `floral-mongoose-1792497995`, region `eu-north-1`, namespace `online-shop` | Functional validation, image inspection and disposable Kubernetes operations tests | Two AMD64 Ready nodes; 11 application Deployments available, 11 Pods running at final observation |

The reference source is `asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo`, commit `218ba3dcef1d19821711e62996162f8b29c55be4`, artifact `release/kubernetes-manifests.yaml`. Its original release contains 12 Deployments and 12 Services. The existing EKS environment contains 11 Deployments and does not run `loadgenerator`; do not claim identical manifests or identical deployment procedures.

## 3. Work performed

### CAP04-001: Architecture and planning

- Analyzed existing Online Boutique source and Kubernetes release structure.
- Created architecture, scope/requirements, use-case and delivery documents.
- Kept official TWN rubric verification separate from proposed portfolio acceptance criteria.

### CAP04-002: Isolated local Kubernetes cluster

- Implemented a local k3d lifecycle script with preflight, create, verify, namespace, status and confirmed destroy operations.
- Explicitly scoped all kubectl operations to a named k3d context.
- Prepared `online-boutique` namespace for release resources.

### CAP04-003: Release deployment and application verification

- Created pinned-source download, sanity-check and strict Kubernetes server-side dry-run workflow.
- Applied all 24 release resource definitions to k3d using interactive confirmation.
- Investigated local cartservice crashes and frontend HTTP 500, observing AMD64-only image incompatibility against an ARM64 node; **local end-to-end success was not achieved**.
- Reused an existing EKS application for independent runtime verification (did not redeploy whole system).
- Verified manually: frontend HTTP 200, product catalog, product details, add-to-cart and simulated checkout.
- Found incorrect EKS `adservice` image, applied scoped correction, verified 1/1 Ready, revision 2, zero restarts and gRPC ad-request logs.

### CAP04-004: Kubernetes operations

- **Self-healing:** deployed isolated pause Pod/Deployment; deleted that disposable Pod; observed ReplicaSet create a Ready replacement; cleaned up.
- **Rolling update and rollback:** changed separate disposable Deployment from `pause:3.10` to `pause:3.9`; observed revision 2; rolled back to `pause:3.10` in revision 3; cleaned up.
- These tests verify controller and rollout mechanics, **not** production high availability or traffic-level zero downtime.

### CAP04-005: Portfolio closeout

- Consolidated evidence and acceptance results.
- Documented risks, lessons learned, GitHub PR milestone traceability and safe operating boundaries.
- Authored command-level runbook for the local cluster, deployment and read-only EKS evidence scripts.
- Verified local `main` synchronized with GitHub and clean at commit `4beb27b` (operator terminal output, 24 October 2026).
- Re-ran EKS evidence script after the image correction: all 11 Deployments available; all 11 Pods Running and zero restarts at that observation.

## 4. Acceptance and evidence

| Test | Recorded result | Evidence location |
|---|---|---|
| Release download from pinned Git revision | PASS | `docs/deployment.md` |
| Release Kubernetes API server validation | PASS | `docs/deployment.md` |
| Local k3d manifest apply | PASS for API resource submission | `docs/deployment.md` |
| Local k3d checkout | **FAIL**: cartservice crashing/HTTP 500 | `docs/deployment.md` |
| Existing EKS workload inventory | PASS: 11/11 Deployments and Pods healthy at final capture | `scripts/capstone04-eks-evidence.sh`; `docs/portfolio-evidence.md` |
| EKS frontend catalog/product/cart/mock checkout | PASS, manual | `docs/deployment.md` |
| EKS Adservice correction | PASS, runtime health and gRPC requests verified | `docs/deployment.md` |
| Disposable Pod self-healing | PASS | `docs/operations-self-healing.md` |
| Disposable rolling update/rollback | PASS | `docs/operations-rolling-update.md` |
| Cleanup of both demo Deployments | PASS | Operations documents |
| Exact EKS manifest/source reproducibility | **OPEN** | `docs/lessons-learned.md` |
| TWN official acceptance / badge | **NOT VERIFIED** | Requires course portal/instructor confirmation |

**Final observed image:** `Deployment/adservice` used `gcr.io/google-samples/microservices-demo/adservice:v0.8.0`; live Adservice received application requests after correction.

## 5. Operational safety and engineering decisions

- The release deploy script is **restricted to local k3d** and requests explicit interactive confirmation before applying resource changes.
- A separate EKS evidence script checks named AWS cluster status and kubeconfig API endpoint, then performs **read-only** resource inventory.
- Kubernetes test operations use lightweight disposable Deployments, not the single-replica Online Boutique frontend.
- No new EKS cluster or public LoadBalancer was created for CAP04-004/005. The existing `frontend-external` LoadBalancer may incur ongoing AWS costs and was deliberately left unchanged.
- Recorded runtime facts are point-in-time; rerun observations when needed.
- Application payment and shipping flows are **simulated**. Redis cart state in the reference manifest is ephemeral.

## 6. Limitations and unresolved items

1. **Original EKS source of truth:** The source manifest that initially deployed `online-shop` on EKS has not been located. `kubectl apply view-last-applied deployment/adservice` still held the incorrect `shippingservice:v0.8.0` after imperative repair. Before future declarative EKS reconciliation, identify ownership and correct the authoritative manifest; do not apply the entire upstream release blindly.
2. **Release parity:** Existing EKS has 11 Deployments; upstream release has 12 including `loadgenerator`. This report does not assert that the omission was deliberately planned or that EKS is an exact upstream reproduction.
3. **Local architecture:** Existing v0.8.0 cartservice did not pass local ARM64 functional tests; no tested local architecture-compatible solution is claimed.
4. **Functional depth:** Adservice logs show incoming gRPC requests, not independently captured browser advertisement rendering. Frontend workflow was manually verified rather than automated in CI.
5. **Production readiness:** No claim of high availability, persistent cart storage, complete security hardening or zero-downtime service rollouts.
6. **Official TWN submission:** Exact external assessment rubric, submission method and certification outcome are not recorded. Confirm separately with the course platform.

## 7. Repository artifacts

| Artifact | Purpose |
|---|---|
| `README.md` | Project overview and repository navigation |
| `docs/architecture.md` | Logical components, dependencies, decisions |
| `docs/deployment.md` | Release workflow, incident and EKS observations |
| `docs/portfolio-evidence.md` | Detailed acceptance evidence matrix |
| `docs/operations-self-healing.md` | Controller recovery demonstration |
| `docs/operations-rolling-update.md` | Rolling update and rollback experiment |
| `docs/lessons-learned.md` | Findings, caveats and follow-up priorities |
| `docs/scripts-reference.md` | Command-by-command runbook for operational scripts |
| `scripts/capstone04-cluster.sh` | Dedicated local k3d lifecycle |
| `scripts/capstone04-deploy.sh` | Local guarded release fetch/validate/apply |
| `scripts/capstone04-eks-evidence.sh` | Read-only AWS EKS evidence |
| `scripts/bootstrap-github.sh` | Historical one-time GitHub repository/PR bootstrap; **do not run on existing repository** |
| `manifests/operations/*.yaml` | Disposable operations test Deployments |

## 8. Submission checklist

- [x] Repository code and Markdown engineering evidence committed on GitHub.
- [x] Final `main` status verified clean and up to date at operator capture.
- [x] Existing EKS Pods and images rechecked following live Adservice repair.
- [x] Self-healing, update/rollback and demo cleanup recorded.
- [x] Incident and remaining risks included rather than masked.
- [ ] Official TWN project requirements compared against the delivered work.
- [ ] Any required instructor screenshots, video or course-portal submission completed.
- [ ] Official course acceptance or digital badge confirmed.

**Submission statement:** This report is suitable as an engineering portfolio narrative and a *draft* for course submission. It must not be represented as approved by TechWorld with Nana until the course assessment is completed.
