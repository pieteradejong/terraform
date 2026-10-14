#!/usr/bin/env bash
# init.sh — fetch the providers so validate and plan can run. Idempotent; exit 0 = ready.
#   ./init.sh
# Runs `terraform init -input=false -backend=false`: providers are downloaded into
# .terraform/ (network), but no backend is configured or touched, so remote state is
# never read or written here. Needs no cloud credentials.
set -euo pipefail
cd "$(dirname "$0")"
case "${1:-}" in -h|--help) sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;; esac
command -v terraform >/dev/null 2>&1 || { echo "terraform not found (brew install terraform)" >&2; exit 1; }
terraform version | head -n1
terraform init -input=false -backend=false
echo "ready: ./test.sh, then ./run.sh (plan; needs AWS credentials)"
