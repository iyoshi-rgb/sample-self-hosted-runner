#!/bin/bash
set -e

# 環境変数チェック
if [[ -z "${GITHUB_REPOSITORY:-}" || -z "${RUNNER_TOKEN:-}" ]]; then
  echo "Error: GITHUB_REPOSITORY と RUNNER_TOKEN を設定してください" >&2
  exit 1
fi

GITHUB_URL="https://github.com/iyoshi-rgb/${GITHUB_REPOSITORY}"

./config.sh --url "${GITHUB_URL}" --token "${RUNNER_TOKEN}" --ephemeral

./run.sh