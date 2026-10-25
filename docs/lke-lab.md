# Capstone 04 — LKE cluster lifecycle (TWN Lesson 22)

The existing EKS and local k3d evidence remains unchanged. This isolated, optional **LKE** reproduction follows the 11-microservice deployment lesson. Nothing is provisioned by adding this file.

## Preconditions
- Mac with Bash 3.2+ or newer, `linode-cli` v5.69.0, `jq`, `kubectl`, `base64`
- Authenticated Linode account (never commit tokens)
- Account currently reported **no existing LKE clusters**; recheck before using
- Choose a node plan based on the workload; `g6-standard-2` is a tentative 4 GiB/2-vCPU plan, not proof of adequacy
- Version `1.35` was offered by the account on 2026-10-25; validate availability again

## Workflow

```bash
git switch feat/cap04-lke-deployment
bash scripts/capstone04-lke.sh preflight
bash scripts/capstone04-lke.sh create       # Requires explicit CREATE-... confirmation; starts billing
bash scripts/capstone04-lke.sh kubeconfig   # Once API kubeconfig becomes available
bash scripts/capstone04-lke.sh verify       # Requires 3 Ready workers
```

The isolated kubeconfig is saved outside Git to `~/.kube/twn-capstone04-lke.yaml`. Do **not** merge it into your default EKS kubeconfig.

`create` computes an estimated **worker-only hourly charge** using the CLI pricing feed. The account reported `g6-standard-2` at **USD 0.036 per node-hour**, so three workers are **USD 0.108/hour** and nominally **USD 72/month**, excluding region-specific changes, NodeBalancers, volumes and other billable services. `g6-standard-4` was USD 0.072 per node-hour, totaling USD 0.216/hour for three. These are point-in-time estimates, not spending caps. Set `NODE_TYPE=g6-standard-4` only after cost approval.

## Scope and safety
- The lifecycle script only manages the **named dedicated cluster**, not EKS or local k3d.
- Do not apply upstream full-stack YAML to the existing EKS namespace.
- Deploy the microservices in an isolated namespace only after the three workers are Ready, using a separately reviewed, version-pinned manifest workflow.
- A `LoadBalancer` Service can create additional paid NodeBalancers.
- Confirm browser catalog/cart/simulated checkout and capture evidence before deleting the lab.
- Clean up with `bash scripts/capstone04-lke.sh destroy`, which requires entering the numeric cluster ID. Then review **remaining NodeBalancers and Block Storage volumes** manually in Cloud Manager.
- The exercise is **not** an assertion of TWN official acceptance.

Akamai reference: https://techdocs.akamai.com/linode-api/reference/post-lke-cluster and https://techdocs.akamai.com/linode-api/reference/delete-lke-cluster.
