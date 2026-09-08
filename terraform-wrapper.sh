#!/usr/bin/env bash
# Terraform Wrapper Script
# Usage: ./terraform-wrapper.sh -e production plan
#        ./terraform-wrapper.sh -e development apply

set -euo pipefail

VALID_ENVIRONMENTS=("development" "testing" "staging" "production")

ENVIRONMENT=""
TERRAFORM_ARGS=()
HAS_E_FLAG=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -e)
      ENVIRONMENT="${2:-}"
      HAS_E_FLAG=true
      shift 2
      ;;
    *)
      TERRAFORM_ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ "$HAS_E_FLAG" == true ]]; then
  if [[ -z "$ENVIRONMENT" ]]; then
    echo "Error: Environment is required after -e flag"
    echo "Valid environments: ${VALID_ENVIRONMENTS[*]}"
    exit 1
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
    exit 1
  fi

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [[ -f "$SCRIPT_DIR/scripts/terraform-workspace.sh" ]]; then
    "$SCRIPT_DIR/scripts/terraform-workspace.sh" -e "$ENVIRONMENT"
  else
    echo "Error: terraform-workspace.sh not found"
    exit 1
  fi
fi

if [[ ${#TERRAFORM_ARGS[@]} -eq 0 ]]; then
  terraform
else
  terraform "${TERRAFORM_ARGS[@]}"
fi
