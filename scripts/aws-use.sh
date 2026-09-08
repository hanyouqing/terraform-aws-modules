#!/usr/bin/env bash
# Switch AWS CLI profile / region helpers for local development.
# Usage:
#   source scripts/aws-use.sh <profile> [region]
#   aws_use my-sso-profile us-east-1

aws_use() {
  local profile="${1:-}"
  local region="${2:-${AWS_DEFAULT_REGION:-us-east-1}}"

  if [[ -z "$profile" ]]; then
    echo "Usage: aws_use <profile> [region]"
    return 1
  fi

  export AWS_PROFILE="$profile"
  export AWS_DEFAULT_REGION="$region"
  export AWS_REGION="$region"

  echo "AWS_PROFILE=$AWS_PROFILE"
  echo "AWS_REGION=$AWS_REGION"
  aws sts get-caller-identity 2>/dev/null || echo "Warning: could not call sts (login with aws sso login?)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  aws_use "$@"
fi
