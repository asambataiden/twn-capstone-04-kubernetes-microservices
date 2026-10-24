# CAP04-004 — Rolling Update and Rollback (EKS)

**Date:** 24 October 2026  
**Status:** Operator demonstrated and verified — **PASS**  
**Cluster:** pre-existing TWN EKS `floral-mongoose-1792497995`, region `eu-north-1`  
**Namespace:** `online-shop`  
**Isolation:** temporary `Deployment/cap04-rolling-update-demo`; no updates to the Online Boutique frontend or other application services.

## Purpose

Demonstrate Kubernetes Deployment revision creation, rolling update, rollback, readiness and safe cleanup with versioned images on the existing AMD64 EKS nodes. This is an operational mechanics demonstration using a disposable `pause` container, not a production-like zero-downtime test.

## Prerequisites and guardrails

- Verify explicit Kubernetes context and namespace; never rely on the current context.
- Verify resource availability and confirm `cap04-rolling-update-demo` does **not** already exist.
- Use the version-controlled `manifests/operations/rolling-update-demo.yaml` (initially created locally by the operator; commit separately).
- Before deploying, operator confirmed `registry.k8s.io/pause:3.10` and `registry.k8s.io/pause:3.9` both have `linux/amd64` manifests.
- The Deployment defines one replica, a separate selector, non-root execution, no service account token mount and resource bounds. It exposes no public Service.

## Reproducing the exercise

```bash
CTX='aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io'
NS='online-shop'
APP='cap04-rolling-update-demo'
MANIFEST='manifests/operations/rolling-update-demo.yaml'

# No output expected; stop if an existing Deployment is returned.
kubectl --context "$CTX" -n "$NS" get deployment "$APP" --ignore-not-found
kubectl --context "$CTX" -n "$NS" apply --dry-run=server -f "$MANIFEST"
kubectl --context "$CTX" -n "$NS" apply -f "$MANIFEST"
kubectl --context "$CTX" -n "$NS" rollout status deployment/"$APP" --timeout=120s

# Imperative image change strictly scoped to disposable Deployment.
kubectl --context "$CTX" -n "$NS" set image deployment/"$APP" \
  pause=registry.k8s.io/pause:3.9
kubectl --context "$CTX" -n "$NS" rollout status deployment/"$APP" --timeout=120s
kubectl --context "$CTX" -n "$NS" rollout history deployment/"$APP"

# Roll back to previous Pod template.
kubectl --context "$CTX" -n "$NS" rollout undo deployment/"$APP"
kubectl --context "$CTX" -n "$NS" rollout status deployment/"$APP" --timeout=120s
kubectl --context "$CTX" -n "$NS" get deployment "$APP" \
  -o 'jsonpath={.spec.template.spec.containers[0].image}{"\n"}'
kubectl --context "$CTX" -n "$NS" get pods -l app="$APP"
kubectl --context "$CTX" -n "$NS" rollout history deployment/"$APP"

# Clean up ONLY the disposable test Deployment.
kubectl --context "$CTX" -n "$NS" delete -f "$MANIFEST"
kubectl --context "$CTX" -n "$NS" get deployment "$APP" --ignore-not-found
```

## Observed acceptance results

| Step | Evidence | Outcome |
|---|---|---|
| Registry verification | Both images offer `linux/amd64` | PASS |
| API dry-run | `deployment.apps/cap04-rolling-update-demo created (server dry run)` | PASS |
| Initial apply | Deployment created and rollout successful | PASS |
| Update | `kubectl set image` to `pause:3.9` succeeded | PASS |
| Update readiness | Rollout successful; Pod `1/1 Running`, 0 restarts | PASS |
| Revision history after update | Revisions `1` and `2` | PASS |
| Rollback | `kubectl rollout undo` succeeded; rollout became healthy | PASS |
| Restored image | `registry.k8s.io/pause:3.10` | PASS |
| Revision history after rollback | Revisions `2` and `3` | PASS |
| Cleanup | Deployment deletion confirmed; subsequent `get --ignore-not-found` returned no resource | PASS |

Kubernetes can record a rollback as a new Deployment revision: reverting the Pod template is another update. This demonstration shows successful update/rollback reconciliation; with one replica and a process-less pause image, it does **not** establish serving-traffic availability or zero downtime.

### Important declarative-management caveat

The operator received:

> resource deployments/cap04-rolling-update-demo was previously managed with 'kubectl apply'. Rolling back will not update the kubectl.kubernetes.io/last-applied-configuration annotation ...

This is expected when mixing client-side `kubectl apply` tracking with imperative `kubectl set image` and `kubectl rollout undo`. In a long-lived deployment, update the Git-managed source of truth to the desired image and reconcile from that; do not rely on rollback alone as a permanent configuration state. The disposable resource was deleted after the successful exercise.

## Scope and follow-up

This completes CAP04-004's optional rolling-update/rollback demonstration with no intentional changes to existing Online Boutique Deployments. Commit the local test manifest into `feat/cap04-004-kubernetes-operations`. CAP04-003 still requires final EKS image inventory/source provenance verification before its PR is marked complete.
