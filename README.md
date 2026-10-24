# TWN Capstone 04 — Deploy Microservices Application in Kubernetes

**Status:** CAP04-001 — Architecture, requirements, and use-case baseline (planning only; no cluster deployed).

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

## Scope and guardrails

- Reuse the **existing** microservices and prebuilt images. No unnecessary business application rewrite.
- Preserve compatibility with a simple local Kubernetes learning experience.
- Begin with the existing **`release/kubernetes-manifests.yaml`**; do not apply `kubernetes-manifests/` directly without Skaffold's image substitution.
- Design for cloud portability; defer any provider-specific choice until the official TWN assignment is confirmed.
- Keep core assignment delivery distinct from optional independent enhancements.
- Apply secure defaults, reproducible configuration, explicit resource limits, validation and rollback procedures where practical.
- Treat the existing source repository as a reference; make capstone-specific changes in an independent repository/branch.

## Next decision

**CAP04-002: Choose the cluster runtime and prove a minimal deployment.** Default for initial verification is a local `kind` cluster when host resources permit; use a managed cluster only if official TWN requirements call for it. First obtain the exact Project 04 assessment/submission instructions.

## Current evidence

CAP04-001 documents existing GitHub source; no Kubernetes deployment, checkout journey, automatic recovery or rollout test is claimed yet.
