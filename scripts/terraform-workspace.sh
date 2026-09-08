#!/usr/bin/env bash
# Terraform Workspace Management Script
# Usage: terraform-workspace.sh -e <environment>
# Valid environments: development, testing, staging, production

set -euo pipefail

VALID_ENVIRONMENTS=("development" "testing" "staging" "production")

usage() {
  echo "Usage: $0 -e <environment>"
  echo ""
  echo "Valid environments:"
  for env in "${VALID_ENVIRONMENTS[@]}"; do
    echo "  - $env"
  done
  exit 1
}

ENVIRONMENT=""
while getopts "e:h" opt; do
  case $opt in
    e) ENVIRONMENT="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [[ -z "$ENVIRONMENT" ]]; then
  echo "Error: Environment is required"
  usage
fi

VALID=false
for env in "${VALID_ENVIRONMENTS[@]}"; do
  if [[ "$ENVIRONMENT" == "$env" ]]; then
    VALID=true
    break
  fi
done

if [[ "$VALID" == false ]]; then
  echo "Error: Invalid environment '$ENVIRONMENT'"
  echo "Valid environments are: ${VALID_ENVIRONMENTS[*]}"
  exit 1
fi

if ! command -v terraform &>/dev/null; then
  echo "Error: terraform command not found"
  exit 1
fi

CURRENT_WORKSPACE=$(terraform workspace show 2>/dev/null || echo "default")

if ! terraform workspace list 2>/dev/null | grep -qE "[[:space:]]${ENVIRONMENT}$|^\\*?[[:space:]]*${ENVIRONMENT}$"; then
  echo "Workspace '$ENVIRONMENT' does not exist. Creating it..."
  terraform workspace new "$ENVIRONMENT"
else
  terraform workspace select "$ENVIRONMENT"
fi

echo "Workspace: $(terraform workspace show) (was: $CURRENT_WORKSPACE)"
