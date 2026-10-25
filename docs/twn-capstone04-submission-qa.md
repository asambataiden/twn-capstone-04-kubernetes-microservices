# Capstone 04 — TWN DevOps Bootcamp submission questions and answers

**Project:** Deploy Microservices Application in Kubernetes  
**Course:** TechWorld with Nana — DevOps Bootcamp, Module 10, Lesson 22  
**Implementation:** Online Boutique on Linode Kubernetes Engine (LKE)  
**Completed:** 25 October 2026  
**Assessment status:** Engineering work and manual validation completed; **official TWN review/acceptance not yet confirmed**.

> **Important:** The headings below are reusable answers to *likely* portfolio/badge-form questions, not a transcription of an authenticated TWN submission form. If the form uses different questions or limits, adapt the response without changing the underlying facts.

## Repository links

- **Capstone 04 (submit this):** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices
- **Source microservices application (reference/study repository):** https://github.com/asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo
- **LKE deployment evidence:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/evidence/lke-lesson22-2026-10-25.md
- **Deployment script:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/scripts/capstone04-lke-deploy.sh
- **Cluster lifecycle script:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/scripts/capstone04-lke.sh
- **LKE instructions:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/docs/lke-lab.md
- **Architecture:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/docs/architecture.md
- **TWN checklist gap analysis:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/docs/module10-official-checklist-gap-analysis.md
- **Implementation PR:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/pull/13
- **Cleanup/closure PR:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/pull/14

**Repository visibility:** The capstone portfolio repository was private at the last verified GitHub metadata check. Ensure reviewers have access or intentionally choose the appropriate visibility after a secrets/history review. Do not submit an inaccessible private link.

---

## Suggested submission responses — copy and adapt to the actual form

### Q1. What is the project name?

**Answer:** DevOps Bootcamp — Capstone 04: Deploy Microservices Application in Kubernetes (Online Boutique on Linode Kubernetes Engine).

### Q2. What problem or objective did the project address?

**Answer:** The objective was to deploy an existing multi-service application to a managed Kubernetes cluster, configure Deployment and Service resources in a dedicated namespace, verify internal service communication, and make the frontend accessible for an end-to-end shopping demonstration. I followed TechWorld with Nana Module 10, Lesson 22, with a three-worker-node Linode Kubernetes Engine cluster.

### Q3. Which technologies and services did you use?

**Answer:** Linode Kubernetes Engine (LKE), Kubernetes v1.35.9, `kubectl`, Linode CLI v5.69.0, Bash, `jq`, `curl`, Git, GitHub, Kubernetes Deployments, ClusterIP Services, namespaces, rolling rollout checks, and the Google Online Boutique v0.8.0 sample microservices application. The app includes a Redis cart service and simulated checkout dependencies.

### Q4. How did you build and deploy the application?

**Answer:** I created a dedicated LKE cluster in Frankfurt (`eu-central`) with three worker nodes using a guarded Bash lifecycle script. I retrieved an isolated kubeconfig, confirmed all workers were Ready, then created the `online-shop` namespace. I used a commit-pinned Online Boutique v0.8.0 release as input and a documented script that removed only the optional `loadgenerator` Deployment and the public `frontend-external` LoadBalancer Service from a temporary rendered copy. The resulting 11 Deployments and 11 internal Services passed Kubernetes server-side dry-run validation and were applied after explicit confirmation.

**Implementation boundary:** These were derived from pinned upstream manifests, **not 11 Kubernetes manifests independently authored from scratch**.

### Q5. How was the microservices application configured?

**Answer:** Eleven application Deployments were deployed to `online-shop`: `adservice`, `cartservice`, `checkoutservice`, `currencyservice`, `emailservice`, `frontend`, `paymentservice`, `productcatalogservice`, `recommendationservice`, `redis-cart`, and `shippingservice`. They were exposed through 11 internal ClusterIP Services. The frontend was accessed from my Mac through a temporary `kubectl port-forward`, avoiding creation of an additional cloud LoadBalancer.

### Q6. What was the final result, and how did you validate it?

**Answer:** The three LKE workers were Ready. Kubernetes reported all 11 Deployments available at 1/1 and all 11 Pods Running and Ready. A rollout status check succeeded for every Deployment. The frontend returned HTTP 200 through localhost port-forwarding on port 18080. I also manually confirmed that the storefront displayed the product catalogue and product details, allowed adding products to the cart, and completed the simulated checkout workflow. These are recorded **operator-run/manual checks**, not automated end-to-end tests.

### Q7. What challenges did you encounter, and how did you resolve them?

**Answer:** The new LKE cluster's kubeconfig was initially unavailable and the Linode CLI returned HTTP 503 during provisioning. I updated the lifecycle script to give a clear retry instruction and use macOS-compatible decoding, then retrieved the kubeconfig successfully. On my Mac, port 8080 was already occupied by another application returning HTTP 302 to `/login`; I used port 18080 instead and obtained HTTP 200 from the Online Boutique frontend. Two Pods also experienced initial startup restarts (`emailservice` three and `recommendationservice` one) but both were Ready at subsequent checks.

**Separate earlier learning:** Local k3d on Apple Silicon ARM64 had an upstream cartservice image compatibility issue. The later LKE installation on AMD64 passed the documented shopping workflow. Do not describe the local k3d checkout as successful.

### Q8. What DevOps and security best practices did you apply?

**Answer:** I used Git-controlled scripts and documentation, a pinned source commit, isolated kubeconfig storage outside Git, explicit target checks to avoid accidentally changing other clusters, preflight verification, Kubernetes server-side dry-run, confirmation gates for mutating operations, named namespaces, private ClusterIP Services, and evidence-based rollout and HTTP validation. I avoided creating a public LoadBalancer for this lab, documented limitations honestly, and deleted the temporary cluster and checked billable resource categories after finishing.

These controls support repeatability, safe cloud operations, cost awareness, and separation of concerns. This is a training deployment; it is **not represented as a fully production-hardened, highly available platform**.

### Q9. Where is the project source code and evidence?

**Answer:** My Capstone 04 implementation, automation scripts, runbooks and verification evidence are in:

https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices

The original Online Boutique study/source repository used for the pinned release is:

https://github.com/asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo

The dedicated LKE evidence report is:

https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices/blob/main/evidence/lke-lesson22-2026-10-25.md

### Q10. Is the cloud environment still running?

**Answer:** No. After validating the application, I deleted the dedicated LKE cluster (ID `676998`). A subsequent Linode CLI audit returned empty lists for LKE clusters, NodeBalancers and Block Storage volumes in the configured account. This confirms those resource categories were empty at the time of inspection; it is not a final billing statement.

### Q11. Were all official course requirements completed and accepted?

**Answer:** I completed and documented a functional reproduction of the main Module 10 Lesson 22 demonstration on a three-node LKE cluster. The original TWN lesson checklist refers to authoring 11 Deployment/Service manifests; my implementation used a filtered, pinned upstream release instead, so that *specific authoring step* should be regarded as partially aligned. Lesson 23's full production/security hardening and subsequent Helm/Helmfile lessons are separate exercises and are not claimed here. Official instructor validation and badge acceptance have not yet been confirmed.

---

## Short project description (recommended for a single free-text field)

I completed a Kubernetes microservices deployment project from TechWorld with Nana's DevOps Bootcamp (Module 10, Lesson 22). I provisioned a dedicated three-worker Linode Kubernetes Engine cluster, deployed 11 Online Boutique microservices and 11 internal ClusterIP Services in the `online-shop` namespace using a pinned reference release and version-controlled Bash scripts, and verified all Deployments were Ready. I validated frontend HTTP 200 and manually tested the catalogue, product details, cart and simulated checkout. The GitHub repository includes lifecycle/deployment automation, runbooks, rollout evidence, troubleshooting notes and secure cleanup. I deleted the LKE lab after testing and verified no LKE clusters, NodeBalancers or volumes remained listed. I distinguish the upstream-derived manifests from independently authored manifests and do not claim official TWN approval.

**GitHub:** https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices

## Very short version (when the form has a strict character limit)

Deployed Google Online Boutique on a 3-node Linode LKE cluster with 11 Kubernetes Deployments and 11 internal Services. Verified all rollouts, HTTP 200, catalogue, cart and simulated checkout. Documented reproducible scripts, troubleshooting and complete LKE cleanup. Source: https://github.com/asambataiden/twn-capstone-04-kubernetes-microservices

## Reviewer verification checklist

- [x] Three Ready LKE workers, Kubernetes v1.35.9 (operator evidence).
- [x] Exactly 11 Deployments and 11 internal ClusterIP Services.
- [x] All Deployments Ready and rollout status successful.
- [x] Frontend HTTP 200; manual shopping workflow completed.
- [x] Versioned source, deployment and lifecycle scripts on GitHub.
- [x] LKE cluster destroyed; cluster/NodeBalancer/volume lists empty on inspection.
- [ ] Independent screenshots/video attached if the official form specifically requires them.
- [ ] Reviewer access to private GitHub repository verified.
- [ ] Actual course validation/submission receipt and official instructor acceptance confirmed.

## Evidence and integrity guidance

Use the **Capstone 04 portfolio repository** as the main submission URL; the reference application repository is supporting source material. Share only facts confirmed by the linked evidence. Never upload cloud credentials, kubeconfig, bearer tokens or unredacted secret-bearing logs. Don't claim public load-balancer deployment, automated shopping tests, separately authored full YAML files, or official badge acceptance.

**Related:** [LKE deployment evidence](../evidence/lke-lesson22-2026-10-25.md) · [LKE runbook](lke-lab.md) · [Lesson 22/23 checklist analysis](module10-official-checklist-gap-analysis.md)
