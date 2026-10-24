# TWN Module 10 — Lesson 23 Live EKS Configuration Audit

**Date:** 24 October 2026  
**Cluster:** pre-existing EKS `floral-mongoose-1792497995`, `eu-north-1`  
**Namespace:** `online-shop`  
**Method:** Operator executed a **read-only** `kubectl get deployments -o json | jq ...` query.  
**Checklist basis:** TechWorld with Nana *10 - Kubernetes Checklist.pdf*, page 13 — Lesson 23, Production & Security Best Practices.

## Observed deployment configuration

A `YES` means the Kubernetes container specification contains the relevant field; this audit does **not** verify the field's correctness or whether a configured probe truly exercises an application-specific health endpoint.

| Deployment | Desired replicas | Liveness | Readiness | Resource requests | Resource limits |
|---|---:|---|---|---|---|
| adservice | 1 | YES | YES | YES | YES |
| cartservice | 1 | YES | YES | NO | NO |
| checkoutservice | 1 | YES | YES | NO | NO |
| currencyservice | 1 | YES | YES | NO | NO |
| emailservice | 1 | YES | YES | YES | YES |
| frontend | 1 | NO | NO | NO | NO |
| paymentservice | 1 | YES | YES | NO | NO |
| productcatalogservice | 1 | YES | YES | NO | NO |
| recommendationservice | 1 | YES | YES | NO | NO |
| redis-cart | 1 | YES | YES | YES | YES |
| shippingservice | 1 | YES | YES | NO | NO |

**Totals:** liveness 10/11, readiness 10/11, requests 3/11, limits 3/11, desired replicas greater than 1: 0/11. All values are observations of the pre-existing EKS installation; this report did not change cluster resources.

## Mapping to TWN Lesson 23 seven best practices

| TWN checklist item | Assessment | Basis |
|---|---|---|
| BP1: Version each container image | **Partial** | Microservice images were reported at `v0.8.0`; prior EKS inventory showed Redis uses `redis:alpine` (floating tag), not a pinned version/digest. |
| BP2: Liveness probes | **10/11** | Frontend container lacks `livenessProbe`. |
| BP3: Readiness probes | **10/11** | Frontend container lacks `readinessProbe`. |
| BP4: Resource requests | **3/11** | Present on adservice, emailservice, redis-cart only. |
| BP5: Resource limits | **3/11** | Present on adservice, emailservice, redis-cart only. |
| BP6: Do not use NodePort for external connections | **Partial / unverified exposure** | Prior inventory showed frontend `NodePort` and `frontend-external` `LoadBalancer`. NodePort exposure through node firewall/security group was not independently audited. |
| BP7: More than one replica per Deployment | **0/11** | All `.spec.replicas` are 1. |

### Risk observations and boundaries

- **Frontend:** Missing both health probes and CPU/memory requests/limits. This is a high-priority workload to review but is **not** permission to change it unilaterally.
- **Scheduling:** Missing CPU/memory requests can make resource scheduling and contention harder to predict. Existing EKS worker utilization was previously observed as constrained, so increasing replicas without capacity planning may cause Pods to remain Pending.
- **Health:** Probe presence alone is insufficient; review probe type, path/port, thresholds and startup timeouts before any change. `redis-cart` has its own state/data-loss considerations.
- **Replicas:** Increasing replicas can change state, data usage and operational costs. One replica means no workload redundancy is demonstrated; it does not alone prove current outages.
- **Exposure:** A Service of type LoadBalancer commonly has allocated NodePorts as part of its implementation; do not delete or alter Services solely on the basis of the type inventory. An explicit separate frontend NodePort Service is currently present.
- **Reproducibility:** The original EKS declarative source of truth remains unidentified. The live `adservice` image was repaired, but its prior last-applied configuration referenced the incorrect image. Do not blindly reconcile the full upstream reference release.

## Read-only evidence command

```bash
CTX='aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io'
NS='online-shop'
kubectl --context "$CTX" -n "$NS" get deployments -o json | jq -r '
  .items[] |
  .metadata.name as $name |
  .spec.replicas as $replicas |
  .spec.template.spec.containers[] |
  [
    $name,
    ($replicas | tostring),
    (if .livenessProbe then "YES" else "NO" end),
    (if .readinessProbe then "YES" else "NO" end),
    (if .resources.requests then "YES" else "NO" end),
    (if .resources.limits then "YES" else "NO" end)
  ] | @tsv
' | column -t
```

This command produces one row per container. **In the observed cluster each Deployment had one container**, so the recorded totals use 11 rows.

## Recommended controlled next phase

1. **Inspect read-only** full frontend Deployment YAML, and all 11 Service types, port mappings and labels; collect CPU/memory metrics where available.
2. **Design changes in version-controlled, owned, environment-specific YAML** rather than editing the existing EKS cluster imperatively. Keep original source provenance and application ownership visible.
3. **For a separate Lesson 23 improvement exercise**, add meaningful frontend probes, resource requests/limits per actual measurements, pinned Redis version and risk-assessed replicas/entrypoint configuration. Validate manifests via client/server dry-run against an explicitly chosen isolated environment before applying.
4. **Avoid immediate EKS changes:** do not scale replicas or create a new public ingress, add a third node, or apply the complete upstream release to the shared EKS namespace for checklist compliance alone.
5. **Verify outcome** with actual rollout, application-level end-to-end tests and safe rollback on an authorized target. Record any unmet criteria factually.

### Related documents

- [Official TWN Module 10 checklist gap analysis](module10-official-checklist-gap-analysis.md)
- [Portfolio evidence](portfolio-evidence.md)
- [Deployment history and adservice correction](deployment.md)
- [Operations safety runbook](scripts-reference.md)

**Conclusion:** The existing installation demonstrated functional Online Boutique workflows, but this independent Lesson 23 audit shows the 7-point production configuration checklist is **not fully implemented**. Documentation of these observed gaps does not substitute for a future controlled implementation.
