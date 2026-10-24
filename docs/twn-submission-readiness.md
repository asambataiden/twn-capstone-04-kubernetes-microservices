# CAP04 — TechWorld with Nana Submission Readiness

**Checked:** 24 October 2026  
**Status:** GitHub project portfolio complete; course-specific validation details and submission outcome remain **unverified**.

## 1. Source distinction: public course information vs private assignment

The following facts are from **public TWN materials** (and are not a substitute for the authenticated course instructions).

| Public source | Confirmed information | Link |
|---|---|---|
| TWN Bootcamp public curriculum | Module 10, **Container Orchestration with Kubernetes**, includes lesson **22 — Demo project: Deploy Microservices Application** (34:14). Other lessons separately cover Helm and Helmfile. | https://techworld-with-nana.teachable.com/p/devops-bootcamp-curriculum |
| TWN DevOps Bootcamp public description | Bootcamp includes hands-on projects, source-control portfolio and Kubernetes / EKS learning. | https://www.techworld-with-nana.com/devops-bootcamp |
| Credly: Certified DevOps Practitioner | Earning criteria include completing a 16-module program and **passing validation by submitting Git projects for capstone projects built throughout the bootcamp**. | https://www.credly.com/org/techworld-with-nana/badge/certified-devops-practitioner |

The public pages **do not verify** the exact requirements, grading rubric, acceptable cluster type, mandatory loadgenerator, allowed reuse of an existing EKS deployment, required screenshots, submission URL or exact course progress conditions for this specific Capstone 04.

## 2. GitHub portfolio evidence ready to supply

**Repository:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices

| Item | Path | Status |
|---|---|---|
| Project overview and technical boundaries | `README.md` | Present |
| Architecture | `docs/architecture.md` | Present |
| Requirements and proposed use cases | `docs/requirements.md`, `docs/use-cases.md` | Present |
| Local Kubernetes cluster lifecycle | `scripts/capstone04-cluster.sh` | Present |
| Pinned source release deployment automation | `scripts/capstone04-deploy.sh` | Present; **k3d-only** |
| Existing EKS inventory | `scripts/capstone04-eks-evidence.sh` | Present; **read-only** |
| Deployment and troubleshooting | `docs/deployment.md` | Present |
| Operator acceptance matrix | `docs/portfolio-evidence.md` | Present |
| Self-healing and rollback evidence | `docs/operations-self-healing.md`, `docs/operations-rolling-update.md` | Present |
| Four-script operator reference | `docs/scripts-reference.md` | Present |
| Final report | `docs/final-submission-report.md` | Present |
| Lessons learned and remaining risks | `docs/lessons-learned.md` | Present |

## 3. Important qualifications to disclose in any submission

1. **Local k3d release:** Kubernetes accepted and applied upstream manifests, but the ARM64 test failed to complete checkout when the upstream AMD64-only cartservice v0.8.0 crashed.
2. **Existing EKS:** The operator verified working catalog/details/cart/mock checkout on a pre-existing EKS application with 11/11 Deployments available. The capstone's k3d deployment script **did not provision or deploy** this existing EKS installation.
3. **Application version drift:** The pinned original upstream release has 12 Deployments including `loadgenerator`; the EKS installation has 11 and does not include loadgenerator.
4. **Adservice correction:** The EKS `adservice` Deployment was live-corrected to `adservice:v0.8.0`, observed Ready and serving requests. Its last-applied annotation still contained `shippingservice:v0.8.0` at inspection time. The original EKS source manifest is not identified.
5. **Operational tests:** Self-healing and rolling-update/rollback experiments used disposable pause workloads, not the real storefront. They are demonstrations of Kubernetes mechanics, not real-application zero-downtime guarantees.
6. **Course status:** GitHub engineering milestones have been merged, but there is no evidence yet of an officially accepted TWN project or awarded credential.

## 4. Course portal verification procedure

1. Open the authenticated TWN course and review **Module 10 — Container Orchestration with Kubernetes**, particularly **Lesson 22: Demo project: Deploy Microservices Application** and its linked resources, handout or checklist.
2. Open **0 — Getting Started with the Bootcamp**, particularly **Lesson 3: How to Prepare for Digital Badge Certificate [IMPORTANT]**, to identify validation and Git project evidence requirements.
3. Compare any private project instructions against `docs/portfolio-evidence.md`; note which criteria are satisfied, partly satisfied, unmet or not applicable.
4. Establish whether TWN accepts the original Online Boutique release, an existing EKS deployment, operator terminal evidence, and documentation-based incident analysis. **Do not assume acceptance.**
5. Supply the repository URL and whichever evidence format the actual portal requires; retain the confirmation/receipt after submission.
6. Only mark this project's validation as accepted when the course platform/instructor confirms it.

## 5. Decision table once the private rubric is available

| Private requirement (to be copied verbatim or summarized accurately) | Repository evidence | Assessment |
|---|---|---|
| Exact application and source | Pinned Online Boutique release metadata | **To verify against rubric** |
| Exact target cluster/runtime | Local k3d test + existing EKS observations | **To verify against rubric** |
| Required microservices/workloads | 11 observed in EKS vs 12 in pinned original | **To verify against rubric** |
| Mandatory UI shopping workflow | Operator manual EKS catalog, cart and demo checkout | Recorded; acceptance depends on rubric |
| Networking/ingress requirement | Existing NodePort and LoadBalancer + local port-forward | **To verify against rubric** |
| Required Kubernetes operations | Disposable self-healing and rollback exercises | Recorded; acceptance depends on rubric |
| Mandatory course validation/upload | No submitted confirmation available | **Open** |

## 6. Suggested short submission summary (adapt to the actual form)

> **Project:** TWN DevOps Bootcamp Capstone 04 — Kubernetes Microservices.  
> **GitHub:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices  
> **Summary:** I documented and validated the Online Boutique microservices application on Kubernetes, including version-pinned local deployment automation, an ARM64 compatibility incident, inspection and functional verification of an existing EKS deployment, a targeted image correction, and disposable self-healing/rolling-update/rollback demonstrations. The README links to the architecture, operator runbook, test evidence, and final report. The repository explicitly records unresolved EKS declarative source-of-truth and upstream-parity differences.

**Before sending:** If the portal has its own title, checklist or evidence requirements, follow that wording and format. This summary describes a GitHub engineering portfolio, not an assertion of instructor approval.
