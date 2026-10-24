# CAP04 — TWN Module 10 Checklist Gap Analysis

**Reviewed:** 24 October 2026  
**Primary evidence:** Operator-provided **10 - Kubernetes Checklist.pdf** (TechWorld with Nana, 15 pages); **10 - Kubernetes Handout.pdf** (89 pages); course portal screenshots showing Module 10 lesson list and progress.  
**Scope:** Compare the *actual attached lesson checklist*, particularly pages 12–14, to the documented CAP04 GitHub portfolio. This is a **self-assessment**, not a verified instructor score.

## Lesson 22: Demo Project — Deploy Microservices Application

The following is **directly from checklist page 12**, not an inferred official grading rubric.

| TWN demo-executed item | CAP04 evidence | Assessment |
|---|---|---|
| Created YAML file with **11 Deployment and corresponding Service manifests** | Pinned upstream release contains **12 Deployments and 12 Services**. Existing EKS has **11 Deployments**, but no independently identified authored/owned EKS manifest; local k3d script downloads reference YAML rather than authoring a separate 11-Deployment configuration | **Partial** |
| All Service components internal, except browser-accessible Frontend | Existing EKS Adservice Service is ClusterIP; frontend has existing NodePort and LoadBalancer access. A service-by-service complete audit is not in CAP04 evidence | **Partial / mostly evidenced** |
| Created K8s cluster with **3 worker nodes** on Linode or another cloud | Existing EKS cluster has **two** Ready AMD64 worker nodes; creation within CAP04 not evidenced (cluster pre-existed). Local k3d lab has a single server node, no dedicated agents | **Not satisfied literally** |
| Connected to cluster | kubectl context-scoped connectivity and EKS API identity verified | **Passed** |
| Created Namespace and deployed all microservices into it | Local k3d namespace created and full pinned reference applied, but cartservice ARM64 incident blocked functional acceptance. Existing EKS `online-shop` has 11 healthy Deployments; original cluster deployment source/action not captured | **Partial** |
| Accessed Online Shop with browser | Existing EKS frontend HTTP 200; user manually confirmed catalog, product details, add-to-cart and simulated checkout | **Passed** |

### Important interpretation

The lesson's 11 Deployments does **not** establish the exact identity of the 11 services in the operator's existing EKS installation. The source-pinned reference has 12 Deployments including loadgenerator. Count agreement alone cannot prove upstream content equivalence. Likewise the checklist demonstrates activities, but does not explicitly say every item is an independent pass/fail digital-badge criterion.

**Do not create a third EKS node or redeploy existing workloads without verifying whether the checklist expects exact historical exercise reproduction or accepts an equivalent demonstration.** Worker-node additions may incur charges and affect shared-cluster scheduling. Do not falsely mark the three-node criterion as passed.

## Lesson 23: Production & Security Best Practices (checklist page 13)

The PDF lists seven separate changes to the microservices configuration:

| TWN item | Current CAP04 evidence | Assessment |
|---|---|---|
| BP1 Add image version | Most sample images use `v0.8.0`, but EKS Redis uses floating `redis:alpine` | **Partial** |
| BP2 Liveness probe per container | Adservice liveness probe verified; not audited for every service | **Not completely verified** |
| BP3 Readiness probe per container | Adservice readiness probe verified; not audited for every service | **Not completely verified** |
| BP4 Resource requests | Adservice verified; not audited across all services | **Not completely verified** |
| BP5 Resource limits | Adservice verified; not audited across all services | **Not completely verified** |
| BP6 Avoid NodePort Service type | Existing frontend Service is NodePort; separate existing frontend-external LoadBalancer also exists | **Not satisfied literally** |
| BP7 More than one replica per Deployment | Existing EKS evidence had one available replica of each workload | **Not satisfied** |

This is **a distinct course lesson**. The CAP04-004 disposable Pod replacement and rolling update exercises demonstrate Kubernetes mechanics; they do not satisfy a literal multi-replica Online Boutique production-configuration requirement. No full-stack EKS modification was performed merely to satisfy the checklist.

## Lessons 24–25: Separate projects (checklist page 14)

- **Lesson 24** asks the learner to create a `microservices` Helm Chart, per-service `values.yaml`, and a Redis Helm Chart/values file.
- **Lesson 25** asks the learner to deploy using `helm install`, create/install Helmfile and deploy Helm Charts using Helmfile.
- These are **subsequent distinct demo lessons**. CAP04 as scoped here does not contain verified custom Helm/Helmfile work and must not claim these as completed by this portfolio repository.

## Further Module 10 checklist coverage

Pages 4–11 separately cover introduction/architecture, Minikube/kubectl, MongoDB/Mongo Express, Namespaces, Services/Ingress/Gateway API, volumes, ConfigMap/Secrets, StatefulSets, managed clusters, Helm, private registry, Operators and RBAC. These are course/module exercises and are not automatically established by the CAP04 project. The attached course screenshot showed Module 10 at **97%**, with Lesson 10 (Ingress) partly complete at capture time; most surrounding lessons show completed ticks. This is course progress UI, not an official assessment result.

The 89-page handout's pages 86–89 reinforce versioned images, probes, requests/limits, avoiding NodePort in production, multiple replicas/nodes, labels, namespaces, container security and image scanning. Those are conceptual/operational recommendations, not evidence that our existing EKS implementation satisfies them.

## Recommended next steps (minimal changes, in order)

1. **Freeze factual documentation:** retain this report and mark the literal three-node, authored 11-manifest, and Lesson 23 configuration conditions as gaps.
2. **Verify service-level configuration read-only:** inspect Services, probes, requests, limits, replicas and images on the existing EKS installation with an explicitly pinned context. Do not apply the upstream 24-resource manifest to a shared live namespace.
3. **Obtain exact Lesson 22 attached project YAML / handout instructions, if any**, and distinguish what TWN actually wants shown from what the module checklist records as a learning exercise.
4. **Document provenance gap:** locate and correct the original EKS `adservice` source of truth before future `kubectl apply`. Current live deployment is correct but old client-side last-applied data may contain shippingservice image.
5. **Do not add a third EKS node, ingress controller, replicas or Helm installation** without first confirming these are required for this particular evidence/submission and determining security, cost, capacity and application effects.
6. If validating the **whole Module 10** rather than **Lesson 22/CAP04**, track Lesson 23 best-practice changes and Lessons 24–25 Helm/Helmfile as **separate** exercises with their own evidence; do not backfill those results into CAP04 without testing.
7. **Official digital badge submission requirements:** the attached checklist is a study-progress checklist. It does not itself specify authenticated submission URL, Git evidence validation form, or assessor approval; those remain to be confirmed.

## Related CAP04 evidence

- [Portfolio acceptance matrix](portfolio-evidence.md)
- [Existing EKS and local k3d deployment evidence](deployment.md)
- [Final submission report](final-submission-report.md)
- [Lessons learned](lessons-learned.md)
- [TWN submission readiness overview](twn-submission-readiness.md)

**Bottom line:** CAP04 documents valuable working Kubernetes operations and manual EKS Online Boutique business functionality. It should be described as **partially aligned** with Lesson 22's explicit implementation checklist rather than fully satisfying all the exercise's prescribed steps.
