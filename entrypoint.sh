#!/bin/bash
set -e

RUNNER_TOKEN=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${PAT_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/iyoshi-rgb/${GITHUB_REPOSITORY}/actions/runners/registration-token \
  | jq -r '.token')

if [[ -z "${GITHUB_REPOSITORY:-}" || -z "${RUNNER_TOKEN:-}" ]]; then
  echo "Error: GITHUB_REPOSITORYを設定してください" >&2
  exit 1
fi

GITHUB_URL="https://github.com/iyoshi-rgb/${GITHUB_REPOSITORY}"

./config.sh --url "${GITHUB_URL}" --token "${RUNNER_TOKEN}" --ephemeral --unattended

./run.sh