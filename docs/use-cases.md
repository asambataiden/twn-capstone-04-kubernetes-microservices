# CAP04-001 — Use Cases and Acceptance Scenarios

All items below are **planned validation scenarios**; none are marked executed.

## UC-01 — Deploy existing microservices to Kubernetes

**Actor:** DevOps engineer.

**Preconditions:** A functioning cluster, working `kubectl` context, sufficient resources and access to release images.

**Flow:** Inspect release manifest → validate resources → deploy in selected namespace → monitor Deployment rollout and Pod readiness → inspect Services.

**Acceptance:** Required application Deployments become available; no unresolved failing Pods; service endpoints exist; evidence is captured.

**Failure paths:** Image pull error, insufficient resources, probe failure, unsupported manifest API, wrong namespace/context.

## UC-02 — Browse products through the frontend

**Actor:** Online shopper/tester.

**Preconditions:** Frontend and product catalog healthy; frontend accessible through port-forward or approved ingress.

**Flow:** Open online shop → load product grid → select product → view details.

**Acceptance:** HTTP UI accessible and expected products/details rendered.

## UC-03 — Add to cart and complete simulated checkout

**Actor:** Online shopper/tester.

**Preconditions:** Frontend, cartservice/Redis, checkout, payment, currency, shipping and email services are available.

**Flow:** Add product → inspect cart → enter/use demo checkout details → complete mock checkout.

**Acceptance:** Cart changes visible and demo checkout confirms an order. **Payment and shipping are simulated, not real external financial transactions.**

## UC-04 — Validate internal networking

**Actor:** DevOps engineer.

**Flow:** Inspect `ClusterIP` Services → confirm environment-based service addresses and port mappings → exercise frontend workflows → inspect relevant Pods and events if errors occur.

**Acceptance:** App uses Kubernetes service discovery; no backend exposed publicly solely for inter-service calls.

## UC-05 — Demonstrate stateless Pod recovery (extension)

**Actor:** DevOps engineer.

**Preconditions:** All required Pods healthy; choose stateless frontend or catalog Pod, not Redis.

**Flow:** Record current Pod IDs → delete one Pod controlled by a Deployment → observe replacement → wait for Ready status → rerun product-browsing test.

**Acceptance:** A new Pod is created and eventually Ready; frontend continues/returns to expected behavior; observation and duration recorded. Do not assert zero downtime without measurement.

## UC-06 — Demonstrate a controlled rollout and rollback (extension)

**Actor:** DevOps engineer.

**Preconditions:** Known baseline revision and safe, reversible deployment change.

**Flow:** Record baseline → apply validated revision → observe rolling rollout → perform health check → revert to previous revision → confirm recovery.

**Acceptance:** Both forward and rollback transitions have explicit rollout status and functional evidence. Not part of the minimum implementation.

## UC-07 — Repeatable teardown

**Actor:** DevOps engineer.

**Flow:** Save evidence → identify cluster/namespace resources created by the capstone → delete only scoped resources or dedicated local test cluster → verify cleanup.

**Acceptance:** No unexpected resource deletion and no avoidable paid cloud infrastructure left running.
