#!/usr/bin/env bash
# test.sh — every check in one place. Exit 0 = green.
#   ./test.sh
# Steps: shell, secrets (no tracked .env or state), fmt (terraform fmt -check -recursive),
# validate (terraform validate; needs ./init.sh once). No credentials, no network.
set -euo pipefail
cd "$(dirname "$0")"
case "${1:-}" in
    -h|--help) sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    "") ;;
    *) echo "Unknown option: $1 (see ./test.sh --help)" >&2; exit 2 ;;
esac
command -v terraform >/dev/null 2>&1 || { echo "terraform not found (brew install terraform)" >&2; exit 1; }

echo "== shell"
for f in ./*.sh; do bash -n "$f"; /bin/bash -n "$f"; done
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -S warning ./*.sh
else
    echo "shellcheck not installed — syntax-checked only (brew install shellcheck)"
fi

echo "== secrets"
tracked="$(git ls-files | grep -E '(^|/)(\.env(\..+)?|.*\.tfstate(\..*)?|.*\.tfvars)$' | grep -vE '\.env\.(example|template)$|\.tfvars\.example$' || true)"
if [ -n "$tracked" ]; then
    echo "env, state and tfvars files must never be tracked:"; echo "$tracked"; exit 1
fi
echo "no tracked env, state or tfvars files"

echo "== fmt"
terraform fmt -check -recursive -diff

echo "== validate"
[ -d .terraform ] || { echo ".terraform/ missing — run ./init.sh first" >&2; exit 1; }
terraform validate

echo "== all green"
