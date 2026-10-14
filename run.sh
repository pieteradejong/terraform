#!/usr/bin/env bash
# run.sh — read-only Terraform entry points. Run ./init.sh once first.
#   ./run.sh [plan]    terraform plan (default; read-only, needs AWS credentials)
#   ./run.sh fmt       terraform fmt -recursive (rewrites files)
#   ./run.sh validate  terraform validate
#   ./run.sh apply     refuses: run `terraform apply` yourself, deliberately
#   ./run.sh test      delegates to ./test.sh
#   ./run.sh help
set -euo pipefail
cd "$(dirname "$0")"
usage() { sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'; }
cmd="${1:-plan}"
if [ $# -gt 0 ]; then shift; fi
case "$cmd" in
    plan) exec terraform plan -input=false ;;
    fmt) exec terraform fmt -recursive ;;
    validate) exec terraform validate ;;
    apply)
        echo "run.sh never applies. If you mean it: terraform apply" >&2
        exit 2 ;;
    test) exec ./test.sh "$@" ;;
    help|-h|--help) usage ;;
    *) echo "Unknown command: $cmd" >&2; usage >&2; exit 2 ;;
esac
