#!/usr/bin/env bash
set -Eeuo pipefail

# Run from the unzipped CAP04-001 folder on your Mac.
REPO_NAME='twn-capstone-04-kubernetes-microservices'
OWNER='asambataiden'
FEATURE_BRANCH='docs/cap04-001-architecture-baseline'

for executable in git gh; do
  if ! command -v "$executable" >/dev/null 2>&1; then
    printf 'Missing dependency: %s\n' "$executable" >&2
    exit 1
  fi
done

gh auth status >/dev/null

if [[ -d .git ]]; then
  echo 'Refusing to initialize an existing Git repository.' >&2
  exit 1
fi
if [[ ! -f README.md || ! -f docs/requirements.md || ! -f docs/architecture.md ]]; then
  echo 'Run from the extracted capstone04-001 directory.' >&2
  exit 1
fi
if gh repo view "$OWNER/$REPO_NAME" >/dev/null 2>&1; then
  echo "Repository $OWNER/$REPO_NAME already exists; stopping to avoid overwriting it." >&2
  exit 1
fi

# Keep main minimal. Put the detailed baseline through a normal PR.
cp README.md README.cap04-001.tmp
cat > README.md <<'BASELINE'
# TWN Capstone 04 — Kubernetes Microservices

TechWorld with Nana DevOps Bootcamp capstone. Documentation and deployment are developed through reviewed feature branches.

Reference application: https://github.com/asambataiden/twn-devops-bootcamp-10-kubernetes-deploying-microservices-demo
BASELINE

git init -b main
git add README.md .gitignore
git commit -m 'chore(cap04): initialize capstone repository'
gh repo create "$OWNER/$REPO_NAME" --private --source . --remote origin --push

git switch -c "$FEATURE_BRANCH"
mv README.cap04-001.tmp README.md
git add README.md docs .gitignore scripts/bootstrap-github.sh
git diff --cached --check
git commit -m 'docs(cap04-001): architecture requirements use cases and delivery plan'
git push -u origin "$FEATURE_BRANCH"
gh pr create --base main --head "$FEATURE_BRANCH" \
  --title 'docs(cap04-001): establish architecture and use-case baseline' \
  --body '## Scope
- Analyze the existing Online Boutique reference application and its Kubernetes deployment options.
- Capture verified upstream constraints separately from proposed TWN learning requirements.
- Document initial architecture, use cases, acceptance gates and delivery milestones.

## Validation
- Markdown-only planning baseline; no Kubernetes cluster created or application deployed.
- The exact official TWN Project 04 assignment and runtime are not yet confirmed.

## Next milestone
CAP04-002: confirm the official assignment and cluster resources, then validate the release manifests and deployment environment.'

echo
echo "Created private repo and opened the CAP04-001 PR: https://github.com/$OWNER/$REPO_NAME"
