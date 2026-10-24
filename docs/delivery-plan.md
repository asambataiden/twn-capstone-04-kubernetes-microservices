# CAP04 — Delivery Plan

## CAP04-001 — Architecture, requirements and use cases

- [x] Locate and inspect existing GitHub application source.
- [x] Verify release manifest vs development manifest deployment caveat.
- [x] Document source components and Kubernetes architecture.
- [x] Separate upstream facts, bootcamp-aligned proposals and optional engineering extensions.
- [x] Define acceptance scenarios and evidence expectations.
- [ ] Confirm exact TWN assignment description (not yet available).

**Exit status:** Design baseline prepared; implementation deliberately not started.

## CAP04-002 — Kubernetes environment and baseline

- Choose local `kind` or required managed provider after assessment confirmation.
- Record runtime version, resource capacity and cluster context; ensure there are no stale production contexts.
- Validate the existing release manifest with client/server checks as supported.
- Deploy a minimal, version-pinned baseline using prebuilt images.
- Verify Pods, Services, events and the frontend with a safe local access method.

## CAP04-003 — E-commerce workflow verification

- Exercise product browsing, cart and mock checkout.
- Verify service discovery and document dependencies.
- Save sanitized logs/screenshots and exact manifest revision.

## CAP04-004 — Operational learning extensions (select only if useful)

- Self-healing of a stateless Pod.
- Controlled rolling update and rollback.
- Minimal, justified policy/security improvement supported by the chosen cluster.

## CAP04-005 — Closeout

- Document deployment runbook, security decisions, troubleshooting and test evidence.
- Review differences against initial requirements and TWN assignment.
- Open a feature-branch PR; merge only once relevant validations pass.
- Write a short portfolio project note.

## Risk register

| Risk | Mitigation |
|---|---|
| Official bootcamp assignment differs from proposed baseline | Verify instructions before deployment or submission |
| Cluster insufficient CPU/memory | Check resources before provisioning and reduce optional load generator where supported |
| Public image version not pullable | Check registry/image availability and document any vetted replacement |
| Generated release manifests inadvertently modified | Keep source immutable and isolate changes in overlay or separate config |
| Redis cart data lost during restart | Limit recovery demonstration to stateless Pods |
| Cloud costs unexpectedly accrue | Prefer local cluster and define explicit teardown checklist |
