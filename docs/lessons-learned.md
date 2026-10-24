# CAP04-005 — Lessons Learned, Decisions and Follow-ups

**As of:** 24 October 2026

## Engineering lessons

### 1. Image architecture compatibility is a deployment requirement

The version-pinned Online Boutique `cartservice:v0.8.0` image exposes `linux/amd64` while the local k3d worker is `linux/arm64`. The cart runtime crashed and the frontend returned HTTP 500. Kubernetes API acceptance and a temporary Ready state were not proof of business-flow success.

**Practice:** Inspect supported image platforms and node architecture before deployment; run application-level acceptance tests. Treat emulation-related crashes as investigated symptoms, not proof of a single unique root cause.

### 2. Context and namespace isolation prevent collateral changes

The local scripted deploy is locked to `k3d-twn-capstone04` and `online-boutique`. The existing EKS cluster had constrained node headroom, unrelated monitoring workloads and a public LoadBalancer.

**Practice:** Never redirect an entire release apply to the shared existing EKS environment merely to close a milestone. Inspect resource ownership, cost impact and namespaces first.

### 3. A Ready Pod can run the wrong service

`Deployment/adservice` in existing EKS referenced `shippingservice:v0.8.0` while reporting Ready. Image inventory exposed the defect. A targeted image update deployed the correct `adservice:v0.8.0`; Adservice logs confirmed startup and receipt of gRPC requests.

**Practice:** Compare container name, actual image, ports, upstream contracts and runtime behavior. Treat Pod health and correctness as distinct requirements.

### 4. Imperative repair does not repair declarative provenance

A targeted `kubectl set image` corrected the live EKS Pod template, but `kubectl apply view-last-applied` still records the wrong shipping-service image. No original EKS source manifest path has been verified. The pinned **reference** release manifest is correct but should not be assumed to own the existing EKS installation.

**Practice:** Locate the original authoritative manifest, correct it in Git, review drift and reconcile **only** owned resources. Until that happens, label EKS source-of-truth reproducibility as **open**.

### 5. Controller reconciliation and real application resilience are different

The disposable self-healing demonstration validated ReplicaSet replacement after an intentional Pod deletion. The disposable rolling update/rollback demonstrated Deployment revisions 1→2→3. Neither pause workload serves real traffic.

**Practice:** State exactly what was tested. Do not label the observations as zero-downtime Online Boutique upgrades or automatic recovery of all kinds of application failure.

### 6. Evidence must distinguish local and cloud environments

The k3d test failed the business path for an investigated technical reason; existing EKS passed manual storefront, cart and demo checkout. Combining these into a single unqualified “deployment succeeded” claim would be misleading.

**Practice:** Record cluster, namespace, image, command, expected outcome, actual outcome and limitation for each acceptance check.

## Open follow-ups (not CAP04-005 blockers if retained honestly)

| Priority | Follow-up | Completion evidence |
|---|---|---|
| High | Identify owner/source file for **original existing EKS** manifests and fix stale adservice `last-applied-configuration` | Version-controlled authoritative manifest corrected; safe targeted reconciliation; view-last-applied agrees with running desired configuration |
| Medium | Explicitly verify browser advertisement rendering if required by TWN | Screenshot or controlled functional evidence, without adding a separate testing platform |
| Medium | Decide whether absence of EKS `loadgenerator` is intentional, and record the difference from upstream 12-Deployment release | Written rationale or optional scoped validation, not blind deployment |
| Medium | Verify TechWorld with Nana's exact Capstone 04 assessment/submission requirements | Rubric checklist and submission link / reviewer confirmation |
| Low | Improve repeatable EKS deployment only if actually part of a follow-on scope | Owner-approved declarative deployment workflow with environment-specific manifests and dry-run/rollback plan |

## Operational and security caveats

- The Online Boutique checkout, payment, shipping and email interactions are simulations; do not use real payment information.
- Redis cart data is ephemeral in the referenced deployment and should not be represented as durable state.
- A public EKS LoadBalancer already exists and may incur charges. No new public endpoint is required for capstone documentation.
- Optional Google Cloud telemetry warnings in the Adservice container are nonfatal in the observed AWS environment; do not introduce unnecessary Google credentials.
- Reference to Kubernetes version 1.34, image versions, node conditions and readiness is observation-specific; recheck before future changes.

## Final sign-off boundary

CAP04-001–004 engineering evidence supports **portfolio-ready documentation of the performed experiments and observed application flow**. It does not support the claim that the operator can reproduce the entire existing EKS environment from this repository or that the external TWN badge/submission has been awarded. CAP04-005 is complete only after reviewing and merging its documentation PR.
