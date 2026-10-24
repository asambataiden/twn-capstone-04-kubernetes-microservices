# TWN Capstone 04 — Deploy Microservices Application in Kubernetes

**Status (24 October 2026):** CAP04-001–004 merged; CAP04-005 portfolio documentation in review. Existing EKS application tests passed, but declarative EKS reproducibility and official TWN assessment remain unverified.

## Goal

Deploy and operate the existing **Online Boutique** e-commerce microservices application on Kubernetes. First demonstrate the TechWorld with Nana-aligned deployment fundamentals; then selectively extend the implementation with meaningful reliability and operational tests.

**Existing application reference:** [asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo](https://github.com/asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo).

## Documentation

| Document | Purpose |
|---|---|
| [Repository analysis](docs/repository-analysis.md) | Inventory of existing code, manifests, deployment paths, constraints |
| [Requirements](docs/requirements.md) | Verified upstream constraints, proposed bootcamp outcomes, decisions |
| [Architecture](docs/architecture.md) | Component/dependency context, Kubernetes architecture, design choices |
| [Use cases](docs/use-cases.md) | User-facing journey and operational DevOps scenarios, acceptance criteria |
| [Delivery plan](docs/delivery-plan.md) | Milestones, implementation and validation gates |
| [Deployment and validation](docs/deployment.md) | Pinned local deployment script, ARM64 incident, EKS validation and targeted Adservice correction |
| [Scripts reference and operator runbook](docs/scripts-reference.md) | All script commands, prerequisites, outputs, risk classifications, troubleshooting and recovery |
| [Final submission report](docs/final-submission-report.md) | Consolidated project narrative, acceptance evidence, limitations and submission checklist |
| [TWN submission readiness](docs/twn-submission-readiness.md) | Public course criteria, Git project evidence and course portal verification gates |
| [Official Module 10 checklist gap analysis](docs/module10-official-checklist-gap-analysis.md) | Checklist-sourced Lesson 22–25 comparison, identified gaps and safe follow-ups |
| [Portfolio acceptance evidence](docs/portfolio-evidence.md) | Acceptance matrix with passed, failed and unresolved checks |
| [Lessons learned and open follow-ups](docs/lessons-learned.md) | Architecture compatibility, ownership, incident findings and remaining limitations |
| [Kubernetes self-healing](docs/operations-self-healing.md) | Disposable Pod replacement exercise and cleanup |
| [Rolling update and rollback](docs/operations-rolling-update.md) | Disposable revision-change and rollback exercise |

## Scope and guardrails

- Reuse the **existing** microservices and prebuilt images. No unnecessary business application rewrite.
- Preserve compatibility with a simple local Kubernetes learning experience.
- Begin with the existing **`release/kubernetes-manifests.yaml`**; do not apply `kubernetes-manifests/` directly without Skaffold's image substitution.
- Design for cloud portability; defer any provider-specific choice until the official TWN assignment is confirmed.
- Keep core assignment delivery distinct from optional independent enhancements.
- Apply secure defaults, reproducible configuration, explicit resource limits, validation and rollback procedures where practical.
- Treat the existing source repository as a reference; make capstone-specific changes in an independent repository/branch.

## CAP04-003 acceptance status

- Local k3d cluster created and upstream application resources applied by a guarded, repeatable script; cartservice v0.8.0 is amd64-only while the k3d worker is arm64, leading to application crashes during testing.
- Existing TWN EKS cluster `floral-mongoose-1792497995` uses two Ready amd64 workers and hosts an already-running Online Boutique deployment in namespace `online-shop`.
- **Operator-confirmed EKS functional results:** frontend HTTP 200, catalog PASS, product details PASS, add-to-cart PASS, simulated checkout PASS.
- **Not yet demonstrated:** CAP04 script reprovisioning/redeploying the EKS installation; exact agreement of EKS running manifest/images with pinned release; loadgenerator working in EKS; TWN rubric compliance.

**Verified since initial CAP04-003 report:** An incorrect EKS `adservice` image was detected and corrected to `adservice:v0.8.0`; the service is Ready and receives gRPC requests. Two CAP04-004 disposable Deployment exercises passed (Pod replacement and rollout/rollback), and both temporary Deployments were deleted. [PR #3](https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/pull/3) and [PR #4](https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/pull/4) are merged. The EKS `adservice` last-applied annotation **still contains the former incorrect image**; the originally applied EKS manifest was not identified. Existing EKS has 11 Deployments (no upstream loadgenerator) and is not proven equivalent to or reproducibly deployed by the pinned 12-Deployment reference. See the [evidence matrix](docs/portfolio-evidence.md).

**Deployment script safety:** `scripts/capstone04-deploy.sh` currently targets only `k3d-twn-capstone04` and namespace `online-boutique`; it must not be run as an EKS deployment procedure.
