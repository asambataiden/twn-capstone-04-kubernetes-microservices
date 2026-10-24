# CAP04-004 — Kubernetes Operations: Self-Healing

**Date:** 24 October 2026  
**Environment:** Pre-existing TWN EKS `floral-mongoose-1792497995`, `eu-north-1`; context `aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io`; namespace `online-shop`.

## Intent and safety

Demonstrate declarative reconciliation by deleting a single Pod from a **disposable** Deployment rather than disrupting the production-like, single-replica Online Boutique frontend. The test runs a pause container without a Service; least-privilege container settings, `automountServiceAccountToken: false`, and resource requests/limits are defined in `manifests/operations/self-healing-demo.yaml` (local manifest created by the operator; commit it to this branch separately).

## Operator results — PASS

1. `kubectl apply --dry-run=server -f manifests/operations/self-healing-demo.yaml` — accepted.
2. Applied `Deployment/cap04-self-healing-demo`; rollout succeeded.
3. Original Pod `cap04-self-healing-demo-774fb4b8c5-wnq29` was `1/1 Running`, zero restarts.
4. Operator explicitly deleted that **test-only** Pod.
5. Kubernetes recreated Pod `cap04-self-healing-demo-774fb4b8c5-vc8nf`, `1/1 Running`, zero restarts; same ReplicaSet `cap04-self-healing-demo-774fb4b8c5`.
6. `kubectl rollout status deployment/cap04-self-healing-demo --timeout=120s` succeeded. Deployment observed `1/1` available.
7. Operator deleted the test Deployment with `kubectl delete -f manifests/operations/self-healing-demo.yaml`, and the API confirmed deletion.

**Conclusion:** Demonstrated Deployment/ReplicaSet-driven self-healing after direct Pod deletion. This does **not** demonstrate zero-downtime failover for a single replica, nor healing of a failed application process without a probe.

## Reproduction

Before following these commands, check EKS identity/context, namespace, available resources, and ensure this test Deployment does not already exist. Set:

```bash
CTX='aws-admin-asamba.tamajong.aiden@outlook.com@floral-mongoose-1792497995.eu-north-1.eksctl.io'
NS=online-shop
MANIFEST=manifests/operations/self-healing-demo.yaml
```

Run manifest validation, guarded apply, rollout, and verification:

```bash
kubectl --context "$CTX" -n "$NS" get deployment cap04-self-healing-demo --ignore-not-found
kubectl --context "$CTX" -n "$NS" apply --dry-run=server -f "$MANIFEST"
kubectl --context "$CTX" -n "$NS" apply -f "$MANIFEST"
kubectl --context "$CTX" -n "$NS" rollout status deployment/cap04-self-healing-demo --timeout=120s
kubectl --context "$CTX" -n "$NS" get pods -l app=cap04-self-healing-demo
```

Only when exactly one ready Pod is present, record its name, then delete **that Pod only**. Watch until a new Pod is Ready, compare names, and verify Deployment availability:

```bash
kubectl --context "$CTX" -n "$NS" get pods -l app=cap04-self-healing-demo
kubectl --context "$CTX" -n "$NS" delete pod <EXACT_TEST_POD_NAME>
kubectl --context "$CTX" -n "$NS" rollout status deployment/cap04-self-healing-demo --timeout=120s
kubectl --context "$CTX" -n "$NS" get deployment,replicaset,pods -l app=cap04-self-healing-demo
```

Clean up test-only resources:

```bash
kubectl --context "$CTX" -n "$NS" delete -f "$MANIFEST"
kubectl --context "$CTX" -n "$NS" get deployment cap04-self-healing-demo --ignore-not-found
```

## Boundaries and next steps

- Existing Online Boutique frontend remains on one replica, revision 1, without a PDB; deliberately do not delete it.
- Existing EKS image inventory and CAP04-003 source-provenance comparison are still pending.
- Any rolling-update/rollback exercise should also use a disposable workload with controlled image versions and no unnecessary public exposure. Observe rollout revisions before relying on `rollout undo`.
- Preserve exact terminal output in sanitized portfolio evidence; do not claim missing results.
