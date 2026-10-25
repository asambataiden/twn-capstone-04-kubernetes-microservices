# CAP04 — Engineering Portfolio Closure

**Updated:** 25 October 2026  
**Disposition:** **Closed as an engineering portfolio project; not yet officially accepted by TWN.**

## Scope concluded

CAP04 documents the Kubernetes deployment of an existing Online Boutique microservices application, using upstream release manifests in a dedicated local k3d environment, and operational/functional validation of a **pre-existing** AWS EKS installation. Self-healing and rolling update/rollback were demonstrated on separate disposable workloads, which were cleaned up.

All five internal engineering milestones, CAP04-001 through CAP04-005, have been merged. The repository includes architecture, requirements, safe operational scripts, deployment evidence, incident notes, portfolio evidence, lessons learned, and a final submission report.

## LKE Lesson 22 reproduction — 2026-10-25

Following the initial engineering closeout, the operator created a dedicated **three-worker Linode LKE** cluster (ID `676998`), deployed **11** Online Boutique application Deployments and **11** internal ClusterIP Services from a pinned version of the upstream release (excluding optional loadgenerator and public LoadBalancer), verified all Deployments Ready and local port-forward HTTP 200, and manually verified catalogue, details, cart and mock checkout. The lab was then deleted; operator queries returned `[]` for remaining LKE clusters, NodeBalancers and volumes. See [LKE evidence](../evidence/lke-lesson22-2026-10-25.md).

This resolves the earlier three-worker-node demonstration gap using LKE. The source was a filtered pinned upstream release, not an independently authored set of 11 manifest files. The earlier EKS and local k3d distinctions remain historically accurate; Lesson 23 hardening and official TWN acceptance are not claimed.

## Demonstrated outcomes

- Version-pinned reference manifests downloaded and validated by Kubernetes API, then applied to local k3d.
- ARM64/AMD64 `cartservice:v0.8.0` incompatibility observed in the local application; **local checkout failed** and is not marked as passed.
- Existing two-worker-node EKS installation verified with 11 available application Deployments and Pods, and manual frontend catalog, details, cart and mock checkout tests passed.
- Scoped live correction of incorrect `adservice` image validated through workload health and gRPC request logs.
- Disposable Kubernetes Pod replacement and rolling update/rollback both passed with demo cleanup.
- Reference source, script operating boundaries, incident history, and acceptance observations documented.

## Exceptions intentionally left open

These issues do not prevent **portfolio** closure but must not be disguised as passing the exact TWN demonstration:

1. The TWN three-worker-node cloud deployment has now been reproduced successfully on LKE. The checklist's independently authored manifest aspect is still only partial because the LKE implementation filters a pinned upstream file. The separate existing EKS cluster has two workers and its original declarative source remains unidentified.
2. Local ARM64 cartservice release could not complete the shopping flow. Successful functionality was independently observed in the pre-existing AMD64 EKS environment; this does not prove that the capstone's deployment script created that EKS installation.
3. Current live EKS `adservice` was repaired, but its earlier last-applied metadata still included the wrong image; its authoritative source manifest needs reconciliation **before any future EKS apply**.
4. TWN Lesson 23's hardening checklist was audited but **not implemented** as part of CAP04; it is separate learning scope. Later Helm/Helmfile lesson work is likewise not part of this closeout.
5. Official instructor validation, submission confirmation, and digital badge award are **not recorded**.

See [official TWN checklist gap analysis](module10-official-checklist-gap-analysis.md), [submission readiness](twn-submission-readiness.md) and [final submission report](final-submission-report.md).

## No further CAP04 engineering changes planned

Do not add EKS worker nodes, scale production-like application Deployments, create new LoadBalancers, deploy Helm/Helmfile or alter existing namespaces merely to close this portfolio. Any separate TWN exercise should live in an independently scoped project with its own testing and source of truth.

## Transition to next TWN project

The next **documented Module 10 demo project** on the provided TWN checklist is **Lesson 24 — Create Helm Chart for Microservices**, followed by Lesson 25 — Deploy Microservices with Helmfile. The handout identifies Helm chart templating, Chart.yaml, values.yaml and templates as the next instructional topics.

This ordering does **not** establish an officially named 'Capstone 05' or prove that Lesson 24 is the next bootcamp-wide capstone. The next project should be titled from the lesson until course documentation confirms an official capstone number.

**Outcome:** CAP04 engineering portfolio completed and frozen. Move to the next independently scoped TWN exercise; retain this repository as historical evidence.
